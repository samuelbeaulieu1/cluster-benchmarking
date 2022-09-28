from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def home():
    instance_id = os.environ["INSTANCE_ID"]
    return f"Instance number {instance_id} is responding now!"

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0')
