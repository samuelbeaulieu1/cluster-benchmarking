import json
import requests
import threading
import time
import os

def call_endpoint_http(count: int = 1):
    url = os.environ["APP_URL"]
    headers = { 'content-type': "application/json" }
    for i in range(0, count):
        req = requests.get(url, headers=headers)
        print(req.status_code)
        print(req.content)

def seq_test():
    call_endpoint_http(1000)

def seq_with_sleep_test():
    call_endpoint_http(500)

    time.sleep(60)

    call_endpoint_http(1000)

if __name__ == "__main__":
    threading.Thread(target=seq_test).start()
    threading.Thread(target=seq_with_sleep_test).start()
