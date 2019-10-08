import sys
import json
import logging
import argparse
import powerdns

OK = 0
KO = 1

logging.basicConfig(filename='/tmp/pdnsupdate.log',
                    filemode='a',
                    level=logging.INFO)


def update_pdns(json_string, **kwargs):
    try:
        logging.debug('Processing consul watch output ' + json_string)
        services = json.loads(json_string)
        for service in services:
            logging.debug('Processing service ' + service)
            update_service(service, **kwargs)
    except json.JSONDecodeError:
        log = 'Malformed input ' + json_string + '. Expected valid json dict'
        sys.stderr.write(log)
        logging.error(log)


def update_service(service, **kwargs):

    pdns_client = powerdns.PDNSApliClient(
        api_endpoint=kwargs['pdns_url'],
        api_key=kwargs['pdns_key'])
    pdns_api = powerdns.PDNSEndpoint(pdns_client)
    pdns_zone = pdns_api.server[0].get_zone(kwargs['pdns_domain'])
    pdns_zone.create_records([
        service + 'service'
    ])
    logging.info('processing service' + service)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--pdns-url')
    parser.add_argument('-k', '--pdns-key')
    parser.add_argument('-z', '--pdns-domain')
    parser.add_argument('-d', '--consul-domain')
    args = vars(parser.parse_args())
    if len(args) != 4:
        parser.print_help()
        sys.exit(KO)
    else:
        for line in sys.stdin:
            update_pdns(line, **args)
