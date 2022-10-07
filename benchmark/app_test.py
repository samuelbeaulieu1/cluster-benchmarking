import json
import requests
import threading
import time
import os
import boto3
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from datetime import date, timedelta, datetime


def call_endpoint_http(cluster:str, lb_domain: str, count: int = 1):
    url = f"http://{lb_domain}/{cluster}"
    headers = {'content-type': "application/json"}
    for i in range(0, count):
        session = requests.Session()
        retry = Retry(connect=5, backoff_factor=0.2)
        adapter = HTTPAdapter(max_retries=retry)
        session.mount("http://", adapter)
        response = session.get(url, headers=headers)
        print(f"{response.text} <{response.status_code}>")


def seq_test(cluster: str, lb_domain: str):
    call_endpoint_http(cluster, lb_domain, 1000)

def seq_with_sleep_test(cluster: str, lb_domain: str):
    call_endpoint_http(cluster, lb_domain, 500)

    time.sleep(60)

    call_endpoint_http(cluster, lb_domain, 1000)

def get_client(resource_name: str):
    return boto3.client(
        service_name=resource_name,
        region_name="us-east-1",
        aws_access_key_id=os.environ["AWS_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["AWS_SECRET_ACCESS_KEY"],
        aws_session_token=os.environ["AWS_SESSION_TOKEN"]
    )

def retrieve_metrics(start_date, end_date, cluster: str, load_balancer):
    load_balancer_arn = load_balancer["LoadBalancerArn"].split("loadbalancer/")[-1]
    target_group_arn = elb.describe_target_groups(Names=[cluster])["TargetGroups"][0]["TargetGroupArn"].split(":")[-1]

    lb_with_target_group_dimension = [
        {
            "Name": "TargetGroup",
            "Value": target_group_arn
        },
        {
            "Name": "LoadBalancer",
            "Value": load_balancer_arn
        }
    ]
    period = 60

    cloudwatch = get_client(resource_name="cloudwatch")
    response = cloudwatch.get_metric_data(MetricDataQueries=[
            {
                "Id": "r1",
                "Label": "Request count for target group",
                "MetricStat": {
                    "Metric": {
                        'Namespace': 'AWS/ApplicationELB',
                        'MetricName': 'RequestCount',
                        "Dimensions": lb_with_target_group_dimension
                    },
                    "Period": period,
                    "Stat": "Sum"
                }
            },
            {
                "Id": "r2",
                "Label": "Response time for target group",
                "MetricStat": {
                    "Metric": {
                        'Namespace': 'AWS/ApplicationELB',
                        'MetricName': 'TargetResponseTime',
                        "Dimensions": lb_with_target_group_dimension
                    },
                    "Period": period,
                    "Stat": "Average"
                }
            },
            {
                "Id": "r3",
                "Label": "Request count per target in target group",
                "MetricStat": {
                    "Metric": {
                        'Namespace': 'AWS/ApplicationELB',
                        'MetricName': 'RequestCountPerTarget',
                        "Dimensions": lb_with_target_group_dimension
                    },
                    "Period": period,
                    "Stat": "Sum"
                }
            }
        ],
        StartTime=start_date,
        EndTime=end_date
    )
    
    metric_results = response["MetricDataResults"]
    metric_output = []
    for metric in metric_results:
        timestamps = list(map(lambda t: t.strftime("%Y-%m-%d %H:%M:%S.%f"), metric["Timestamps"]))
        
        metric_output.append({
            "Label": metric["Label"],
            "Timestamps": timestamps,
            "Values": metric["Values"]
        })
        
    print(f"Results for {cluster}:")
    print(metric_output)


if __name__ == "__main__":
    start = datetime.now()
    threads = []
    elb = get_client("elbv2")
    load_balancer = elb.describe_load_balancers(Names=["c1-c2-alb"])["LoadBalancers"][0]
    lb_domain = load_balancer['DNSName']
    
    threads.append(threading.Thread(target=seq_test, args=["cluster1", lb_domain]))
    threads.append(threading.Thread(target=seq_with_sleep_test, args=["cluster2", lb_domain]))
    
    for thread in threads:
        thread.start()
    
    for thread in threads:
        thread.join()
        
    print("Waiting for cloudwatch to update...")
    time.sleep(120)
    
    end = datetime.now()
    
    retrieve_metrics(start, end, "cluster1", load_balancer)
    retrieve_metrics(start, end, "cluster2", load_balancer)
