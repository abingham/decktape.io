from functools import partial
from itertools import groupby, islice
from Levenshtein import distance


def _get_candidates(target, existing):
    groups = {}
    for dist, group in groupby(existing, partial(distance, target)):
        groups.setdefault(dist, []).extend(group)
    for dist in sorted(groups):
        yield from sorted(groups[dist])


def get_candidates(target, existing, count=10):
    """Get a list of 'matching' candidates for `target` from `existing`.

    This finds the elements of `existing` which match `target` the most closely
    and returns an iterable of up to `count` of the closest matches, sorted by
    closeness.
    """
    return islice(_get_candidates(target, existing), count)
