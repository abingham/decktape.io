from collections import namedtuple
import datetime

import gridfs


IN_PROGRESS = 'in-progress'
COMPLETE = 'complete'
ERROR = 'error'

Metadata = namedtuple('Metadata',
                      ['file_id',
                       'url',
                       'timestamp',
                       'status',
                       'status_msg'])


class ResultDB:
    def __init__(self, db):
        # GridFS of PDF output data and metadata
        self._files = gridfs.GridFS(db)

        # Mapping of file-id to _id in _files.
        self._refs = db['file_ids']

    def create(self, file_id, url):
        """Create a new, empty result file.

        This result will have the status `IN_PROGRESS`. You should update it
        later with results.

        """
        metadata = Metadata(
            file_id=file_id,
            url=url,
            timestamp=datetime.datetime.now(),
            status=IN_PROGRESS,
            status_msg="in progress")

        storage_id = self._files.put(b'', metadata=metadata._asdict())
        self._refs.insert_one({'storage_id': storage_id, 'file_id': file_id})

    def update(self, file_id, data):
        """Update the contents of a result.

        This completely replaces the data in a result file and it sets the
        status to `complete`.

        """
        # Find existing file_id->storage_id mapping
        ref = self._refs.find_one({'file_id': file_id})
        if not ref:
            raise KeyError(
                'No result with ID={}'.format(file_id))

        old_result = self._files.get(ref['storage_id'])

        # Write new data into file storage
        entry = Metadata(file_id=file_id,
                         url=old_result.url,
                         timestamp=datetime.datetime.now(),
                         status=COMPLETE,
                         status_msg='complete')
        new_storage_id = self._files.put(data, **entry._asdict())

        # Update refs to point to new storage
        self._refs.find_one_and_update(
            {'_id': ref._id},
            {'$set': {'storage_id': new_storage_id}})

        # Remove old storage
        self._files.delete(old_result._id)

    def set_error(self, file_id, error_msg):
        """Set a result's status to `error` and record the status message.

        This does not change the contents of the file, if any.

        """
        ref = self._refs.find_one({'file_id': file_id})

        # Directly update the file metadata. This *seems* to be officially
        # supported:
        # https://docs.mongodb.com/manual/core/gridfs/#the-files-collection
        #
        # Err...now we find this! Clearly they don't want us doing this! What to do next...
        md = self._files._GridFS__files.find_one({'_id': ref['storage_id']})['metadata']
        md['status'] = ERROR
        md['status_msg'] = error_msg

        self._files._GridFS__files.find_one_and_update(
            {'_id': ref['storage_id']},
            {'$set': {'metadata': md}})

    def get(self, file_id):
        ref = self._refs.find_one({'file_id': file_id})
        return self._files.get(ref['storage_id'])

    def get_by_url(self, url):
        return self._files.find({'url': url})

    def __iter__(self):
        return self._files.find()
