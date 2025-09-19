#!/bin/bash

# Usage: ./fix_apache_issue.sh <app-server> <ssh-user> <port-number> <process-name>

if [ $# -ne 4 ]; then
  echo "Usage: $0 <app-server> <ssh-user> <port-number> <process-name>"
  exit 1
fi

APP_SERVER=$1
SSH_USER=$2
PORT=$3
PROCESS_NAME=$4

echo "Step 1: Checking connection to $APP_SERVER on port $PORT..."
telnet $APP_SERVER $PORT

echo "Step 2: SSH into $APP_SERVER as $SSH_USER and switch to root..."
ssh -t $SSH_USER@$APP_SERVER "sudo su - <<'EOF'

  echo 'Step 3: Checking Apache HTTPd service status...'
  systemctl status httpd

  echo 'Step 4: Checking which application is listening on port $PORT...'
  sudo netstat -tulnp | grep :$PORT

  echo 'Step 5: Confirming the PID from netstat output for process \"$PROCESS_NAME\"...'
  PID=\$(sudo netstat -tulnp | grep :$PORT | awk '{print \$7}' | cut -d'/' -f1)
  if [ -z \"\$PID\" ]; then
    echo 'No process found listening on the port.'
  else
    echo \"PID found: \$PID\"
    echo 'Verifying process details...'
    ps -ef | grep \$PID | grep -v grep
  fi

  if [ -n \"\$PID\" ]; then
    echo 'Step 6: Killing the running process...'
    kill \$PID
    sleep 2
    echo 'Checking if process is terminated...'
    ps -ef | grep \$PID | grep -v grep || echo 'Process terminated successfully.'
  fi

  echo 'Step 7: Starting Apache HTTPd service and checking status...'
  systemctl start httpd
  systemctl status httpd

  echo 'Step 8: Verifying Apache HTTPd service is listening on port $PORT...'
  netstat -tulnp | grep :$PORT

EOF"

echo "Script execution completed."
