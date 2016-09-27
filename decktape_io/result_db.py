from collections import namedtuple
import datetime
import uuid

import gridfs


IN_PROGRESS = 'in-progress'
COMPLETE = 'complete'
ERROR = 'error'

Metadata = namedtuple('Metadata',
                      ['url',
                       'timestamp',
                       'status',
                       'status_msg'])


class ResultDB:
    def __init__(self, db):
        # GridFS of PDF output data
        self._files = gridfs.GridFS(db)

        # Mapping of file-id to _id in _files.
        self._refs = db['file_ids']

    def create(self, url):
        """Create a new, empty result file.

        This result will have the status `IN_PROGRESS`. You should update it
        later with results.

        Returns a new file-id.
        """
        file_id = str(uuid.uuid1())

        metadata = Metadata(
            url=url,
            timestamp=datetime.datetime.now(),
            status=IN_PROGRESS,
            status_msg="in progress")

        self._refs.insert_one(
            {'storage_id': None,
             'file_id': file_id,
             'metadata': metadata._asdict()})

        return file_id

    def update(self, file_id, data):
        """Update the contents of a result.

        This completely replaces the data in a result file and it sets the
        status to `complete`.

        """
        new_storage_id = self._files.put(data)

        orig = self._refs.find_one_and_update(
            {'file_id': file_id},
            {'$set': {'metadata.status': COMPLETE,
                      'metadata.status_msg': 'complete',
                      'storage_id': new_storage_id,
                      'metadata.timestamp': datetime.datetime.now()}})

        if orig is None:
            self._files.delete(new_storage_id)
            raise KeyError('no file with id {}'.format(file_id))
        else:
            self._files.delete(orig['storage_id'])

    def set_error(self, file_id, error_msg):
        """Set a result's status to `error` and record the status message.

        This does not change the contents of the file, if any.

        """
        orig = self._refs.find_one_and_update(
            {'file_id': file_id},
            {'$set': {'metadata.status': ERROR, 'metadata.status_msg': error_msg}})

        if orig is None:
            raise KeyError('no file with id{}'.format(file_id))

    def _get_impl(self, ref):
        """Returns a tuple (metadata, stream) for a particular ref.
        """
        storage_id = ref['storage_id']
        f = self._files.get(storage_id) if storage_id is not None else None
        return ref['metadata'], f

    def get(self, file_id):
        """Get the metadata and readable data stream for `file_id`.

        Returns:
          A tuple `(metadata, stream)` where `metadata` is a dict of metadata
          information and `stream` is a readable stream of data. `stream` will
          be `None` if there is no data.
        """
        ref = self._refs.find_one({'file_id': file_id})

        if ref is None:
            raise KeyError('no file with id {}'.format(file_id))

        return self._get_impl(ref)

    def get_most_recent(self):
        """Get file-id and metadata for the most recent successful conversions for all
        URLs.

        Returns:
          An iterable of (file-id, metadata) tuples.
        """
        results = self._refs.aggregate([
            {'$match': {'metadata.status': 'complete'}},
            {'$sort': {'metadata.timestamp': -1}},
            {'$group': {'_id': '$metadata.url',
                        'metadata': {'$first': '$metadata'},
                        'file_id': {'$first': '$file_id'}}}
        ])
        return (
            {k: r[k]
             for k
             in ('file_id', 'metadata')}
            for r in results)

    def __iter__(self):
        return self._refs.find()
