import os
import subprocess
import tempfile

import celery
from celery.utils.log import get_logger
import gridfs
import pymongo
import pyramid.httpexceptions

from .result_db import ResultDB

LOG = get_logger(__name__)

app = celery.Celery(
    'cosmic-ray',
    broker='amqp://',
    backend='amqp://')

app.conf.CELERY_ACCEPT_CONTENT = ['json']
app.conf.CELERY_TASK_SERIALIZER = 'json'
app.conf.CELERY_RESULT_SERIALIZER = 'json'


@app.task(name='dektape_io.worker')
def worker_task(file_id,
                url,
                db_host,
                db_port,
                phantomjs_path,
                decktapejs_path):
    # TODO: How can we make this something that persists for the lifetime of
    # the worker?

    # TODO: We should abstract the ResultDB so that details like mongoclient
    # and stuff are hidden elsewhere. Ideally, this code would call
    # "getResultDB()" or something; that function would return the DB, probably
    # getting config values from the paste config. We would of course use this
    # same function in other places where the result DB is used.

    # TODO: It's wrong that we pass in the phantomjs and decktapejs paths. The
    # caller won't generally know these paths as they're specific to the
    # machine on which the worker is running. We need to pass them in on the
    # command line or something.

    client = pymongo.MongoClient(db_host, db_port)
    db = client.decktape_io
    gfs = gridfs.GridFS(db)
    result_db = ResultDB(gfs)

    # TODO: On failure, we need to write something to the DB so clients can
    # know that no output is going to be generated.

    try:
        with tempfile.TemporaryDirectory() as tempdir:
            filename = os.path.join(tempdir, file_id)
            command = [
                phantomjs_path,
                decktapejs_path,
                url,
                filename]

            try:
                subprocess.run(command, check=True)
            except subprocess.CalledProcessError:
                raise pyramid.httpexceptions.HTTPClientError()

            with open(filename, 'rb') as pdf_file:
                result_db.update(
                    file_id,
                    pdf_file.read())
    except Exception as e:
        msg = 'Error performing conversion: {}'.format(e)
        result_db.set_erro(file_id, msg)

def convert_url(*args):
    return worker_task.delay(*args)
