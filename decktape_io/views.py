import pyramid.httpexceptions
from pyramid.response import Response
from pyramid.view import view_config

import json

from .suggestions import get_suggestions
from .worker import convert_url


def _make_result(request, file_id, source_url, timestamp):
    result_url = request.route_url('result', file_id=file_id)

    return {
        'download_url': result_url,
        'source_url': source_url,
        'file_id': file_id,
        'timestamp': timestamp.isoformat()
    }


@view_config(route_name='root', request_method='GET')
def root(request):
    raise pyramid.httpexceptions.HTTPFound("decktape/")


@view_config(route_name='convert',
             request_method='POST',
             renderer='json')
def convert(request):
    """Call this to ask for the conversion of a URL.

    Responds with a JSON object with a 'file_id' which can be used to poll for results.

    """
    url = request.json_body['url']

    file_id = request.result_db.create(url)

    convert_url(
        file_id, url,
        request.registry.settings['mongodb_host'],
        int(request.registry.settings['mongodb_port']),
        request.registry.settings['decktape_phantomjs_path'],
        request.registry.settings['decktape_js_path'])

    result = {
        'source_url': url,
        'file_id': file_id,
        'status_url': request.route_url('status', file_id=file_id)
    }

    return Response(
        body=json.dumps(result),
        charset='UTF-8',
        content_type='application/json')


@view_config(route_name='status',
             request_method='GET',
             renderer='json')
def status(request):
    file_id = request.matchdict['file_id']
    md, _ = request.result_db.get(
        file_id)

    # TODO: Better to use a proper json decoder for timestamps.
    md['timestamp'] = md['timestamp'].isoformat()

    md['download_url'] = request.route_url('result', file_id=file_id)

    return Response(
        json.dumps(md),
        charset='UTF-8',
        content_type='application/json')


@view_config(route_name='result',
             request_method='GET')
def result(request):
    md, f = request.result_db.get(
        request.matchdict['file_id'])
    resp = Response(body=f.read(),
                    content_type='application/pdf')
    return resp


@view_config(route_name='suggestions',
             request_method='GET',
             renderer='json')
def suggestions(request):
    url = request.params['url']
    suggestions = get_suggestions(
        url,
        request.result_db.get_most_recent(),
        lambda r: r['metadata']['url'])

    results = [
        _make_result(request,
                     r['file_id'],
                     r['metadata']['url'],
                     r['metadata']['timestamp'])
        for r in suggestions
    ]

    return Response(
        body=json.dumps(results),
        charset='UTF-8',
        content_type='application/json')
