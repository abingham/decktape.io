import gridfs
import pymongo


class ResultDB:
    def __init__(self, host, port):
        client = pymongo.MongoClient(host, port)
        db = client.decktape_io
        self._gfs = gridfs.GridFS(db)

    def add(self, file_id, data):
        self._gfs.put(data, file_id=file_id)

    def get(self, file_id):
        stored = self._gfs.find_one({'file_id': file_id})
        return stored.read()


def make_result_db(settings):
    return ResultDB(
        settings['mongodb_host'],
        int(settings['mongodb_port']))
