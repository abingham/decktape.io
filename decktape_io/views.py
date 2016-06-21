from pyramid.response import FileResponse
from pyramid.view import view_config


@view_config(route_name='home')
def main_view_in_elm(request):
    response = FileResponse('elm/index.html',
                            request=request,
                            content_type='text/html')
    return response
