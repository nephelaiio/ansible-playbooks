from markupsafe import soft_unicode
import itertools
import sys

if sys.version_info[0] < 3:
    from collections import Sequence, defaultdict
else:
    from collections.abc import Sequence
    from collections import defaultdict


def list2dictlist(xs, key, extra={}):
    return ([{**{key: x}, **extra} for x in xs])


class FilterModule(object):
    ''' jinja2 filters '''

    def filters(self):
        return {
            'list2dictlist': list2dictlist
        }
