import pymongo
from pyramid.config import Configurator

from .result_db import ResultDB
from .routes import configure_routes


def make_result_db(settings):
    client = pymongo.MongoClient(
        settings['mongodb_host'],
        int(settings['mongodb_port']))
    return ResultDB(client.decktape_io)


def make_app(global_config=None, **settings):
    config = Configurator(settings=settings)
    config.include('pyramid_chameleon')

    configure_routes(config)

    result_db = make_result_db(settings)

    # Add a result-db to each request.
    # result_db = make_result_db(settings)
    config.add_request_method(
        lambda req: result_db,
        'result_db',
        reify=True)

    return config.make_wsgi_app()
