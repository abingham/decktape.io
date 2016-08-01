import gridfs
import pymongo
from pyramid.config import Configurator


# TODO: Put this in its own file?
class ResultDB:
    def __init__(self, gfs):
        self._gfs = gfs

    def add_pdf(self, name, data):
        self._gfs.put(data, filename=name)

    def get_pdf(self, name):
        stored = self._gfs.find_one({'filename': name})
        return stored.read()


def make_app(global_config=None, **settings):
    config = Configurator(settings=settings)
    config.include('pyramid_chameleon')
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.add_route('convert', '/convert')
    config.scan()

    # Add a result-db to each request.
    client = pymongo.MongoClient('localhost', 27017)
    db = client.decktape_io
    gfs = gridfs.GridFS(db)
    result_db = ResultDB(gfs)
    config.add_request_method(
        lambda req: result_db,
        'result_db',
        reify=True)

    return config.make_wsgi_app()
