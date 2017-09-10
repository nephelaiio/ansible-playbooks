import sys
import os

sys.path.append(os.path.join(os.path.dirname(sys.path[0]),
                             'playbooks',
                             'filter_plugins'))

print(sys.path)

from custom import reverse_record, filename, with_ext  # noqa: E402


def record(host, address):
    return ({
        'host': host,
        'ip-address': address
    })


def test_reverse_record():
    host = 'test.com'
    address = '10.0.0.1'
    rr = reverse_record(record(host, address))
    assert rr['ip-address'] == host
    assert rr['host'] == '1.0.0.10.in-addr.arpa'
    assert rr['type'] == 'PTR'


def test_filename():
    assert filename('basename.ext') == 'basename'
    assert filename('basename.ext1.ext2') == 'basename'
    assert filename('basename') == 'basename'


def test_with_ext():
    assert with_ext('basename.ext', 'newext') == 'basename.newext'
    assert with_ext('basename.ext1.ext2', 'newext') == 'basename.newext'
    assert with_ext('basename', 'newext') == 'basename.newext'
