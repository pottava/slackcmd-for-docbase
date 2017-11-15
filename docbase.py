import os
import json
import logging
from urllib2 import Request, urlopen

DOCBASE_DOMAIN = os.environ['DOCBASE_DOMAIN']
DOCBASE_TOKEN = os.environ['DOCBASE_TOKEN']
SLACK_TOKEN = os.environ['SLACK_TOKEN']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def respond(err, res=None):
    return {
        'headers': {'Content-Type': 'text/plain; charset=UTF-8'},
        'statusCode': 400 if err else 200,
        'body': err.message if err else res
    }

def search(event, context):
    # logger.info('Event{}'.format(event))
    try:
        params = event['queryStringParameters']
        token = params['token']
        text = params['text']
    except (TypeError, AttributeError):
        logger.error("Request body (%s) is not expected", event['queryStringParameters'])
        return respond(Exception('Invalid request body'))

    if token != SLACK_TOKEN:
        logger.error("Request token (%s) does not match expected", token)
        return respond(Exception('Invalid request token'))

    try:
        req = Request('https://api.docbase.io/teams/{}/posts?q={}'.format(DOCBASE_DOMAIN, text))
        req.add_header('Content-Type', 'application/json')
        req.add_header('X-DocBaseToken', DOCBASE_TOKEN)
        posts = json.loads(urlopen(req).read())['posts']
    except Exception as e:
        logger.error(e)
        return respond(e)

    result = ''
    for x in posts:
        result += "- {title} {url}\n".format(**x)
    if not result:
        result = 'Not found.'

    return respond(None, result)
