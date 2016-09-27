from functools import partial
import stringscore.liquidmetal as lm


def get_candidates(target, records, to_string=None):
    """Sort `records` in descending order of similarity to `target`.

    `records` is some sequence of objects. `target` is a string.

    Before an entry in `records` can be compared to `target`, it must be
    converted to a string. If `to_string` is provided, then it is used as a
    1-ary callable to convert each record to a string for comparison. If it is
    not provided, then the `str` constructor is used.

    Returns an iterable of the sorted records.
    """
    to_string = to_string or str
    score = partial(lm.score, abbrev=target)
    return sorted(records, key=lambda r: score(to_string(r)), reverse=True)
