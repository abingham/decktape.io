from decktape_io.suggestions import get_suggestions
from hypothesis import given
import hypothesis.strategies as st
import stringscore.liquidmetal as lm
import sys


def pairs(l):
    return zip(l, l[1:])


islice_index = st.integers(min_value=0, max_value=sys.maxsize)


def test_empty_existing():
    assert list(get_suggestions('foo', [])) == []


def test_smoke_test():
    existing = ['boo', 'foo', 'food', 'boob', 'goi', 'fee']
    results = list(get_suggestions('foo', existing))
    assert results == ['foo', 'food', 'boo', 'boob', 'goi', 'fee']


@given(st.text(), st.lists(st.text()))
def test_score_order(target, records):
    ordered = list(get_suggestions(target, records))
    scores = [lm.score(r, target) for r in ordered]
    assert scores == sorted(scores, reverse=True)
