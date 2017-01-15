def configure_routes(config):
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_static_view(name='decktape', path='webpack/bundles')
    config.add_route('root', '/')
    config.add_route('convert', '/convert')
    config.add_route('status', '/status/{file_id}')
    config.add_route('result', '/result/{file_id}')
    config.add_route('suggestions', '/suggestions')
    config.scan()
