from .app import make_app


def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    return make_app(global_config, **settings)
