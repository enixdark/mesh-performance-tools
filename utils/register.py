import sys, os
import requests
from urlparse import urlparse
from optparse import OptionParser
import re
import logging
import json 
import gevent
from gevent import monkey
import time
monkey.patch_all()

logger = logging.getLogger(__name__)


# request a register to default server of meshblu http 
def register_default(uri):
    try:
        response = requests.post(uri + "/devices", verify=False, timeout=5)
        logger.info(response.content)
    except requests.RequestException as error:
        logger.error(json.dumps({'error': str(error.message)}))
    return "ok"

# request a register with custom server of meshblu http and pass body to it
def register_with_custom_server(uri, body):
    try:
        response = requests.post(uri + "/ADServer/devices/register", 
                             headers = {'content-type': 'application/json'}, 
                             data = json.dumps(body), verify=False, timeout=5)
        logger.info(response.content)
    except requests.RequestException as error:
        logger.error(json.dumps({'error': str(error.message)}))
    return "ok"

if __name__ == '__main__':
    parser = OptionParser()

    parser.add_option(
        "-p", "--port", dest="port", help="port to run on", default=3000)
    parser.add_option(
        "-H", "--host", dest="host",
        help="which http server to use", default="http://localhost:3000")
    parser.add_option(
        "-c", "--concurrency", dest="concurrency",
        help="Number of concurrent requests", default=1)
    parser.add_option(
        "-d", "--delay", dest="delay",
        help="Delay time for every request", default=1000)
    parser.add_option(
        "-P", "--protocol", dest="protocol",
        help="which protocal to use", default="http")
    parser.add_option(
        "-B", "--body", dest="body",
        help="body content", default=None)
    parser.add_option(
        "-n", "--total", dest="total",
        help="total of requests", default=1)
    parser.add_option(
        "-l", "--logpath", dest="logpath",
        help="path to save a logfile", default='../logs/devices.log')
    (options, args) = parser.parse_args(sys.argv)

    logging.basicConfig(level=logging.INFO)
    handler = logging.FileHandler(options.logpath)
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    logger.addHandler(handler)

    uri = urlparse(options.host)
    host = uri.hostname
    port = uri.port or options.port 
    protocol = uri.scheme or options.protocol 
    delay = int(options.delay) if type(options.delay) is str else options.delay

    concurrency = int(options.concurrency) if type(options.concurrency) is str else options.concurrency
    total = int(options.total) if type(options.total) is str else options.total
    count = 0
    threads = []
    uri_cleaned = protocol + "://" + host + ":" + str(port)
    if options.body:
        if os.path.isfile(options.body):
            data = json.loads(options.body)['devices']            
            for i in xrange(len(data)):
                if count == concurrency:
                    count = 0
                    time.sleep(delay)
                threads.append(gevent.spawn(register_with_custom_server, uri_cleaned, data[i]))
                count = count + 1
            gevent.joinall(threads)

        else:
            body = reduce(lambda x,y: dict(x, **{y[0]: y[1]}), 
                      map(lambda x: re.split(r'=(.+)',x)[0:2], options.body.split(";")), {}
                   )
            for i in xrange(len(data)):
                if count == concurrency:
                    count = 0
                    time.sleep(delay)
                threads.append(gevent.spawn(register_with_custom_server, uri_cleaned, body))
                count = count + 1
            gevent.joinall(threads)
    else:
        for i in xrange(len(data)):
            if count == concurrency:
                count = 0
                time.sleep(delay)
            threads.append(gevent.spawn(register_default, uri_cleaned))
            count = count + 1
        gevent.joinall(threads)
            