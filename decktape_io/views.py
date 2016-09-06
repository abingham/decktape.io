import pyramid.httpexceptions
from pyramid.response import Response
from pyramid.view import view_config

import json
import uuid

from .worker import convert_url


def _make_result(request, file_id, source_url, timestamp):
    result_url = request.route_url('result', file_id=file_id)

    return {
        'result_url': result_url,
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

    Responds with a JSON object with a 'path' field indicating where the output
    file can be found.

    """
    url = request.json_body['url']
    file_id = str(uuid.uuid1())

    convert_url(
        file_id, url,
        request.registry.settings['mongodb_host'],
        int(request.registry.settings['mongodb_port']),
        request.registry.settings['decktape_phantomjs_path'],
        request.registry.settings['decktape_js_path'])

    result = {
        'source_url': url,
        'file_id': file_id
    }

    return Response(
        body=json.dumps(result),
        content_type='application/json')

# TODO: Need to implement polling API. This will include a URL for doing the
# polling as well as changes to the database so that it can store information
# about current state.

@view_config(route_name='result',
             request_method='GET')
def result(request):
    entry = request.result_db.get(
        request.matchdict['file_id'])
    resp = Response(body=entry.read(),
                    content_type='application/pdf')
    return resp


@view_config(route_name='candidates',
             request_method='GET',
             renderer='json')
def candidates(request):
    url = request.params['url']

    results = [
        _make_result(request, r.file_id, r.url, r.timestamp)
        for r in request.result_db.get_by_url(url)]

    return Response(
        body=json.dumps(results),
        content_type='application/json')
