from collections import namedtuple
import datetime
from enum import Enum

import gridfs
import pymongo


class Status(Enum):
    in_progress = 1
    complete = 2
    error = 3

Entry = namedtuple('Entry',
                   ['file_id',
                    'url',
                    'timestamp',
                    'status',
                    'status_msg'])


def _oldest(entries):
        return max(*entries, key=lambda e: e.timestamp)


class ResultDB:
    """Entry metadata looks like:

        file_id: unique id of file
        url: URL from which original presentation came
        timestamp: last modification time
        status: One of the Status enums
        status_msg: A string description of the status, possibly empty
    """
    def __init__(self, host, port):
        client = pymongo.MongoClient(host, port)
        db = client.decktape_io
        self._gfs = gridfs.GridFS(db)
        self._file_ids = db.file_ids

    def create(self, file_id, url):
        entry = Entry(file_id=file_id,
                      url=url,
                      timestamp=datetime.datetime.now(),
                      status=Status.in_progress,
                      status_msg="in progress")

        entry_id = self._gfs.put(b'', **entry)
        self._file_ids.put({'entry_id': entry_id, 'file_id': file_id})

    def update(self, file_id, data):
        old_file_entry = self._file_ids.find_one({'file_id': file_id})
        if not old_file_entry:
            raise KeyError(
                'No entry with ID={}'.format(file_id))

        old_entry_id = old_file_entry['entry_id']

        entry = Entry(file_id=file_id,
                      url=old_file_entry.url,
                      timestamp=datetime.datetime.now(),
                      status=Status.complete,
                      status_msg='complete')
        new_entry_id = self._gfs.put(data, **entry)
        self._gfs.delete(old_entry_id)
        self._file_ids.delete_many({'file_id': file_id})
        self._file_ids.put({'entry_id': new_entry_id, 'file_id': file_id})

    def get(self, file_id):
        entries = self._gfs.find({'file_id': file_id})
        return _oldest(entries);

    def get_by_url(self, url):
        entries = self._gfs.find({'url': url})
        return _oldest(entries)

    def __iter__(self):
        return self._gfs.find()


def make_result_db(settings):
    return ResultDB(
        settings['mongodb_host'],
        int(settings['mongodb_port']))
