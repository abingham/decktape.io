from pyramid.response import FileResponse, Response
from pyramid.view import view_config

import json
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

    Responds with a JSON object with an 'job_id' field. This 'job_id' can be
    used to retrieve the results later.
    """
    url = request.json_body['name']
    job_id = uuid.uuid1()
    # TODO: Request that conversion of 'url' be done, associated with the job-id for later retrieval.

    results = {
        'job_id': job_id
    }

    return Response(
        body=json.dumps(results),
        content_type='application/json')
