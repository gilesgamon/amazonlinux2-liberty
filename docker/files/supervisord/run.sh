#!/bin/bash

# If we're inside an ECS platform
#if [ $AWS_CONTAINER_CREDENTIALS_RELATIVE_URI ] ; then
#  /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
#fi

# Start supervisord
echo "Starting supervisord"
#cd /
#exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
set -u

# Supervisord default params
SUPERVISOR_PARAMS='-c /etc/supervisord.conf'

if [ -d "/config/init/)" ]; then
  for init in /config/init/*.sh; do
    . $init
  done
fi

# We have TTY, so probably an interactive container...
if test -t 0; then
  # Run supervisord detached...
  supervisord $SUPERVISOR_PARAMS
  
  # Some command(s) has been passed to container? Execute them and exit.
  # No commands provided? Run bash.
  if [[ $@ ]]; then 
    eval $@
  else 
    export PS1='[\u@\h : \w]\$ '
    /bin/bash
  fi

# Detached mode? Run supervisord in foreground, which will stay until container is stopped.
else
  # If some extra params were passed, execute them before.
  # @TODO It is a bit confusing that the passed command runs *before* supervisord, 
  #       while in interactive mode they run *after* supervisor.
  #       Not sure about that, but maybe when any command is passed to container,
  #       it should be executed *always* after supervisord? And when the command ends,
  #       container exits as well.
  if [[ $@ ]]; then 
    eval $@
  fi
  supervisord -n $SUPERVISOR_PARAMS
fi