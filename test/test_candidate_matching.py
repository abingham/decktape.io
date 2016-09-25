from decktape_io.candidates import get_candidates


def test_empty_existing():
    assert list(get_candidates('foo', [])) == []


def test_basic_matching():
    existing = ['boo', 'foo', 'food', 'boob', 'goi', 'fee']
    results = list(get_candidates('foo', existing))
    assert results == ['foo', 'boo', 'food', 'boob', 'fee', 'goi']
