import pyramid.httpexceptions
from pyramid.response import FileResponse, Response
from pyramid.view import view_config

import datetime
import json
import os.path
import subprocess
import tempfile
import uuid


def _make_result(request, file_id, source_url, timestamp):
    result_url = request.route_url('result', file_id=file_id)

    return {
        'result_url': result_url,
        'source_url': source_url,
        'file_id': file_id,
        'timestamp': timestamp.isoformat()
    }


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
    # TODO: Request that conversion of 'url' be done, associated with the job-id for later retrieval.

    with tempfile.TemporaryDirectory() as tempdir:
        filename = os.path.join(tempdir, file_id)
        command = [
            request.registry.settings['decktape_phantomjs_path'],
            request.registry.settings['decktape_js_path'],
            url,
            filename]
        timestamp = datetime.datetime.now()

        try:
            subprocess.run(command, check=True)
        except subprocess.CalledProcessError:
            raise pyramid.httpexceptions.HTTPClientError()

        with open(filename, 'rb') as pdf_file:
            request.result_db.add(
                file_id,
                url,
                timestamp,
                pdf_file.read())

    result = _make_result(request, file_id, url, timestamp)
    return Response(
        body=json.dumps(result),
        content_type='application/json')


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
