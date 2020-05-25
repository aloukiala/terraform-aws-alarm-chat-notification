import urllib3
import json
import logging
import os
import datetime
import copy

logger = logging.getLogger()
logger.setLevel(logging.ERROR)

http = urllib3.PoolManager()
URL = os.environ['TEAMS_WEBHOOK_URL']
# Open the message template
with open('message_card_template.json') as json_file:
    message = json.load(json_file)

def lambda_handler(event, context):
    logger.debug(event)
    for record in event['Records']:
        event_message = generate_message(record)
        send_message_to_teams(event_message)
    return True


def generate_message(record):
    """Generate message to chat out of a record from SNS
    
    Arguments:
        record {dict} -- One record of SNS message
    """
    global message
    message_card = copy.deepcopy(message)
    message_card['title'] = record['Sns']['Subject']
    sns_message = json.loads(record['Sns']['Message'])
    message_card['text'] = sns_message['NewStateReason']
    message_card['sections'][0]['facts'] = build_facts(sns_message['StateChangeTime'])
    # NOTE! Parsing the region is based on the SNS topic
    message_card['potentialAction'][0]['actions'][0]['targets'][0]['uri'] = \
        build_metric_link(record['EventSubscriptionArn'].split(':')[3], sns_message['AlarmName'])
    encoded_data = json.dumps(message_card).encode('utf-8')
    logger.debug(encoded_data)
    return encoded_data


def send_message_to_teams(event_message):
    """Send given string message to the teams
    
    Arguments:
        event_message {string} -- String of json in format of Microsoft teams 
        adaptive card
    """
    r = http.request(
        'POST',
        URL,
        body=event_message)
    logger.debug(r.status)
    logger.debug(r.data)


def build_facts(state_change_name):
    """Build the facts shown in the message
    
    Arguments:
        StateChangeTime {string} -- Time of the event
    
    Returns:
        list[key, value] -- Facts for the message
    """
    env = {
        'name': 'Environment',
        'value': os.environ['ENV']
    }
    ts = {
        'name': 'State changed', 
        'value': state_change_name
    }
    return [env, ts]


def build_metric_link(region, alarm_name):
    """Generate URL link to the metric
    
    Arguments:
        region {string} -- aws region name
        alarm_name {string} -- name of the alarm in aws
    
    Returns:
        [type] -- [description]
    """
    url = 'https://{}.console.aws.amazon.com/cloudwatch/home?region={}#alarmsV2:alarm/{}'.format(
        region, region, alarm_name
    )
    return url