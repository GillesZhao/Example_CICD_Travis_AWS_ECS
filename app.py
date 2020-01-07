import time  
import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host='redis', port=6379)

def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return [b"Hello World"]

def get_hit_count():
    retries = 5
    while True:
        try:
            return cache.incr('hits')
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)

@app.route('/')
def hello():
    count = get_hit_count()
    if count == 1:
      return 'Hello World! Juwai website version {} is coming.\n'.format(count)
    else: 
      return 'Hello World! Feature HW-88{} has been successfully applied.\n'.format(count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
