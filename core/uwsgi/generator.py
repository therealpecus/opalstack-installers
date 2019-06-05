import os
user = os.getenv('USER')
name = os.getenv('APPNAME')
port = os.getenv('PORT')
keepalive_path = f'/home/{user}/apps/{name}/start'
keepalive = f'''#!/bin/bash
mkdir -p "$HOME/apps/{name}/tmp"
PIDFILE="$HOME/apps/{name}/tmp/{name}.pid"
if [ -e "${{PIDFILE}}" ] && (ps -u $(whoami) -opid= |
                           grep -P "^\s*$(cat ${{PIDFILE}})$" &> /dev/null); then
  echo "Already running."
  exit 99
fi
echo -n 'Started at '
date "+%Y-%m-%d %H:%M:%S"
/home/{user}/apps/{name}/env/bin/uwsgi -M --http 127.0.0.1:{port} -H /home/{user}/apps/{name}/env/ --wsgi-file /home/{user}/apps/{name}/myapp.wsgi --daemonize /home/{user}/logs/{name}/uwsgi.log --processes 2 --threads 2 --touch-reload /home/{user}/apps/{name}/myapp.wsgi --pidfile $PIDFILE
'''
f = open(keepalive_path, 'w+')
f.write(keepalive)
f.close
print(f'Wrote {keepalive_path}')

kill_path = f'/home/{user}/apps/{name}/kill'
kill = f'''#!/bin/bash
kill -9 `cat $HOME/apps/{name}/tmp/{name}.pid`
'''

f = open(kill_path, 'w+')
f.write(kill)
f.close
print(f'Wrote {kill_path}')

stop_path = f'/home/{user}/apps/{name}/stop'
stop = f'''#!/bin/bash

PIDFILE="$HOME/apps/{name}/tmp/{name}.pid"
if [ -e "${{PIDFILE}}" ] && (ps -u $(whoami) -opid= |
                           grep -P "^\s*$(cat ${{PIDFILE}})$" &> /dev/null); then
/home/{user}/apps/{name}/env/bin/uwsgi --stop /home/{user}/apps/{name}/tmp/{name}.pid
rm  /home/{user}/apps/{name}/tmp/{name}.pid
  exit 99
fi
echo "No PID file"
'''



f = open(stop_path, 'w+')
f.write(stop)
f.close
print(f'Wrote {stop_path}')

myapp_wsgi_path = f'/home/{user}/apps/{name}/myapp.wsgi'
myapp_wsgi = f'''def application(env, start_response):
    start_response('200 OK', [('Content-Type','text/html')])
    return [b'Hello World!']
'''
f = open(myapp_wsgi_path, 'w+')
f.write(myapp_wsgi)
f.close
print(f'Wrote {myapp_wsgi_path}')
