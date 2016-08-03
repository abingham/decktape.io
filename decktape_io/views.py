from pyramid.response import FileResponse, Response
from pyramid.view import view_config

import json
import os.path
import subprocess
import tempfile
import uuid


@view_config(route_name='home')
def main_view_in_elm(request):
    response = FileResponse('elm/index.html',
                            request=request,
                            content_type='text/html')
    return response


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
        subprocess.run(command)
        with open(filename, 'rb') as pdf_file:
            request.result_db.add_pdf(file_id, pdf_file.read())

    pdf_url = request.route_url('result', file_id=file_id)

    results = {
        'result_url': pdf_url,
        'source_url': url,
        'title': file_id
    }

    return Response(
        body=json.dumps(results),
        content_type='application/json')


@view_config(route_name='result',
             request_method='GET')
def result(request):
    data = request.result_db.get_pdf(
        request.matchdict['file_id'])
    resp = Response(body=data,
                    content_type='application/pdf')
    return resp
