import json
import requests
import threading
import time
import os
import boto3
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


def call_endpoint_http(count: int = 1):
    url = os.environ["APP_URL"]
    headers = {'content-type': "application/json"}
    for i in range(0, count):
        session = requests.Session()
        retry = Retry(connect=5, backoff_factor=0.2)
        adapter = HTTPAdapter(max_retries=retry)
        session.mount("http://", adapter)
        response = session.get(url, headers=headers)
        print(f"{response.text} <{response.status_code}>")

def seq_test():
    call_endpoint_http(1000)

def seq_with_sleep_test():
    call_endpoint_http(500)

    time.sleep(60)

    call_endpoint_http(1000)

# TODO: retrieve the actual metrics
def retrieve_metrics():
    cloudwatch = boto3.resource('cloudwatch')
    metric = cloudwatch.Metric('namespace', 'name')


# def lambda_handler(event, context):
#    ec2_client = boto3.client('ec2')
#    CW_client = boto3.client('cloudwatch')
#    region = 'us-east-1'
#    ec2 = boto3.resource('ec2', region_name=region)
#    instances = ec2.instances.all()
#    CPUUtilization_template = '[ "AWS/EC2", "CPUUtilization", "InstanceId", "{}" ]'
#    CPUUtilization_array = []
#    for inst in instances.all():
#        instance_id = inst.id
#        CPUUtilization_array.append(CPUUtilization_template.format(inst.id))
#    CPUUtilization_string = ",".join(CPUUtilization_array)
#    CPUUtilization_instances = r'{"type": "metric","x": 0,"y": 0,"width": 6,"height": 6,"properties": {"view": "timeSeries","stacked": false,"metrics": [template],"region": "us-east-1"}}'.replace(
#        "template", CPUUtilization_string)
#    response = CW_client_put_dashboard(
#        DashboardName='testlambdafunction', DashboardBody='{"widgets":['+CPUUtilization_instances+']}')


if __name__ == "__main__":
    threading.Thread(target=seq_test).start()
    threading.Thread(target=seq_with_sleep_test).start()
