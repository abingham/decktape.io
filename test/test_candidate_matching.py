from decktape_io.candidates import get_candidates
from hypothesis import given
import hypothesis.strategies as st
from Levenshtein import distance
import sys


def pairs(l):
    return zip(l, l[1:])


islice_index = st.integers(min_value=0, max_value=sys.maxsize)


def test_empty_existing():
    assert list(get_candidates('foo', [])) == []


def test_smoke_test():
    existing = ['boo', 'foo', 'food', 'boob', 'goi', 'fee']
    results = list(get_candidates('foo', existing))
    assert results == ['foo', 'boo', 'food', 'boob', 'fee', 'goi']


@given(st.text(), st.lists(st.text()))
def test_distance_is_prioritized(target, examples):
    candidates = list(get_candidates(target, examples, len(examples)))
    for before, after in pairs(candidates):
        assert distance(target, before) <= distance(target, after)


@given(st.text(), st.lists(st.text()))
def test_distance_groups_are_alphabetized(target, examples):
    candidates = list(get_candidates(target, examples))
    for before, after in pairs(candidates):
        if distance(target, before) == distance(target, after):
            assert before <= after


@given(st.text(), st.lists(st.text()), islice_index)
def test_candidate_count_is_not_overrun(target, examples, count):
    candidates = list(get_candidates(target, examples, count))
    assert len(candidates) <= count


@given(st.text(), st.lists(st.text()), islice_index)
def test_candidate_count_is_not_overrun(target, examples, count):
    candidates = list(get_candidates(target, examples, count))
    assert len(candidates) <= count
