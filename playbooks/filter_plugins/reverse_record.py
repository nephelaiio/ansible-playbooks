def reverse_record(record):
    def reverse_address(addr):
        rev = '.'.join(addr.split('.')[::-1])
        return("{0}.{1}".format(rev, 'in-addr.arpa'))
    return ({
        'host': reverse_address(record['ip-address']),
        'ip-address': record['host'],
        'type': 'PTR'
    })


class FilterModule(object):
    ''' jinja2 filters '''

    def filters(self):
        return {'reverse_record': reverse_record}
