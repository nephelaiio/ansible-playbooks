from jinja2.utils import soft_unicode


def filename(basename):
    return (basename.split('.')[0])


def map_format(value, pattern):
    """
    Apply python string formatting on an object:
    .. sourcecode:: jinja
        {{ "%s - %s"|format("Hello?", "Foo!") }}
            -> Hello? - Foo!
    """
    return soft_unicode(pattern) % (value)


def reverse_record(record):
    def reverse_address(addr):
        rev = '.'.join(addr.split('.')[::-1])
        return("{0}.{1}".format(rev, 'in-addr.arpa'))
    return ({
        'host': reverse_address(record['ip-address']),
        'ip-address': record['host'],
        'type': 'PTR'
    })


def with_ext(basename, ext):
    return ("{0}.{1}".format(filename(basename), ext))


class FilterModule(object):
    ''' jinja2 filters '''

    def filters(self):
        return {
            'with_ext': with_ext,
            'filename': filename,
            'map_format': map_format,
            'reverse_record': reverse_record
        }
