from collections import namedtuple
import datetime
from enum import Enum

import gridfs
import pymongo


class Status(Enum):
    in_progress = 1
    complete = 2
    error = 3

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
        self._refs = db.file_ids

    def create(self, file_id, url):
        """Create a new, empty result file.

        This result will have the status `in_progress`. You should update it
        later with results.

        """
        metadata = Metadata(
            file_id=file_id,
            url=url,
            timestamp=datetime.datetime.now(),
            status=Status.in_progress,
            status_msg="in progress")

        storage_id = self._files.put(b'', **metadata)
        self._refs.put({'storage_id': storage_id, 'file_id': file_id})

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
                         status=Status.complete,
                         status_msg='complete')
        new_storage_id = self._files.put(data, **entry)

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
        self._files.fs.files.find_one_and_update(
            {'_id': ref.storage_id},
            {'$set': {'status': Status.error, 'error_msg': error_msg}})

    def get(self, file_id):
        ref = self._refs.find_one({'file_id': file_id})
        return self._files.get(ref['storage_id'])

    def get_by_url(self, url):
        return self._files.find({'url': url})

    def __iter__(self):
        return self._files.find()

# def make_result_db(settings):
#     return ResultDB(
#         settings['mongodb_host'],
#         int(settings['mongodb_port']))
