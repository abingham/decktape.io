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

    def create(self, file_id, url):
        entry = Entry(file_id=file_id,
                      url=url,
                      timestamp=datetime.datetime.now(),
                      status=Status.in_progress,
                      status_msg="in progress")

        self._gfs.put(b'', **entry)

    def update(self, file_id, data):
        old_entry = self._gfs.find_one({'file_id': file_id})

        if not old_entry:
            raise KeyError(
                'No entry with ID={}'.format(file_id))

        entry = Entry(file_id=file_id,
                      url=old_entry.url,
                      timestamp=datetime.datetime.now(),
                      status=Status.complete,
                      status_msg='complete')
        self._gfs.put(data, **entry)
        self._gfs.delete(old_entry._id)

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
