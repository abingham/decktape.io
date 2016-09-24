import decktape_io.result_db as result_db
import pymongo
import pytest
import uuid


@pytest.fixture()
def single_use_db():
    client = pymongo.MongoClient('localhost', 27017)
    db = client['decktape_io_unittests']
    yield result_db.ResultDB(db)
    client.drop_database(db)


@pytest.fixture(scope='module')
def db():
    client = pymongo.MongoClient('localhost', 27017)
    db = client['decktape_io_unittests']
    yield result_db.ResultDB(db)
    client.drop_database(db)


def test_empty_on_construction(single_use_db):
    assert len(list(single_use_db)) == 0


def test_new_entries_get_a_file_id(db):
    file_id = db.create('http://example.com')
    assert file_id is not None


def test_create_adds_entry(db):
    original_size = len(list(db))
    db.create('http://example.com')
    assert len(list(db)) == original_size + 1


def test_new_files_are_in_progress(db):
    file_id = db.create('http://example.com')
    metadata, _ = db.get(file_id)
    assert metadata['status'] == result_db.IN_PROGRESS
    assert metadata['status_msg'] == 'in progress'


def test_error_is_recorded(db):
    file_id = db.create('http://example.com')
    error_msg = 'test_error'
    db.set_error(file_id, error_msg)
    metadata, _ = db.get(file_id)
    assert metadata['status'] == result_db.ERROR
    assert metadata['status_msg'] == error_msg


def test_set_error_with_bad_file_id_throws(db):
    with pytest.raises(KeyError):
        db.set_error(str(uuid.uuid1()), "error")


def test_get_with_bad_file_id_throws(db):
    with pytest.raises(KeyError):
        db.get(str(uuid.uuid1()))


def test_get_by_url_returns_right_data(single_use_db):
    db = single_use_db
    url = 'http://foobar.com'
    file_id = db.create(url)
    results = list(db.get_by_url(url))

    assert len(results) == 1

    for fid, md, _ in db.get_by_url(url):
        assert md['url'] == url
        assert fid == file_id


class TestUpdate:
    def test_update_updates_metadata(self, db):
        file_id = db.create('http://example.com')
        data = b'asdf'
        db.update(file_id, data)
        metadata, _ = db.get(file_id)
        assert metadata['status'] == result_db.COMPLETE
        assert metadata['status_msg'] == 'complete'

    def test_update_updates_data(self, db):
        file_id = db.create('http://example.com')
        data = b'asdf'
        db.update(file_id, data)
        _, f = db.get(file_id)
        assert f.read() == data

    def test_update_with_bad_data_throws_exception(self, db):
        file_id = db.create('http://example.com')
        with pytest.raises(TypeError):
            db.update(file_id, "this is not valid data")

    def test_update_with_bad_file_id_throws(self, db):
        with pytest.raises(KeyError):
            db.update(str(uuid.uuid1()), b'asdf')

    def test_update_with_bad_data_does_not_corrupt(self, db):
        file_id = db.create('http://example.com')

        try:
            db.update(file_id, "not valid data")
            assert False, "You should not get here"
        except TypeError:
            pass

        md, f = db.get(file_id)
        assert f is None
        assert md['status'] == result_db.IN_PROGRESS
        assert md['status_msg'] == 'in progress'
