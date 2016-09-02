import gridfs
import pymongo


class ResultDB:
    def __init__(self, host, port):
        client = pymongo.MongoClient(host, port)
        db = client.decktape_io
        self._gfs = gridfs.GridFS(db)

    def add_pdf(self, name, data):
        self._gfs.put(data, filename=name)

    def get_pdf(self, name):
        stored = self._gfs.find_one({'filename': name})
        return stored.read()


def make_result_db(settings):
    return ResultDB(
        settings['mongodb_host'],
        int(settings['mongodb_port']))
