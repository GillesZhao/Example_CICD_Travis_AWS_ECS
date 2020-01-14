import time
import redis
from flask import Flask

app = Flask(__name__)
cache = redis.Redis(host="0.0.0.0", port=6379)

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
    if count <= 300:
      #return 'Wonderful! Juwai website new version deployed. count = {}\n'.format(count)
      #return 'This is Juwai old website. count = {}\n'.format(count)
      #return 'HW-277 RPC IQI agent registion . count = {}\n'.format(count)
      #return 'HW-287 RPC function for password . \n'.format(count)
      return 'Merge HW-290 RPC python version upgrade into master . \n'
    elif count < 500:
      return 'Hello Guys! Juwai website version {} is coming.\n'.format(count)
    else:
      return 'Hello Juwaiers! Feature HW-8{} has been successfully applied.\n'.format(count)

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
