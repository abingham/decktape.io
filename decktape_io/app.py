from pyramid.config import Configurator

from .result_db import make_result_db


def make_app(global_config=None, **settings):
    config = Configurator(settings=settings)
    config.include('pyramid_chameleon')
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.add_route('convert', '/convert')
    config.add_route('result', '/result/{file_id}')
    config.add_route('candidates', '/candidates')
    config.scan()

    # Add a result-db to each request.
    result_db = make_result_db(settings)
    config.add_request_method(
        lambda req: result_db,
        'result_db',
        reify=True)

    return config.make_wsgi_app()
