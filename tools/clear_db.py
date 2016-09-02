import gridfs
import pymongo

client = pymongo.MongoClient('localhost', 27017)
db = client.decktape_io
gfs = gridfs.GridFS(db)
for record in gfs.find():
    gfs.delete(record._id)
