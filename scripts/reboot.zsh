#!/usr/bin/env zsh

# check for logs directory and create if does not exist
[ ! -d $HOME/logs ] && mkdir $HOME/logs

exec 1> >(tee $HOME/logs/reboot.log) 2>&1

# write time server started reboot to logs
echo "$(hostname) reboot started at $(date +%Y/%m/%d-%H:%M:%S)"

# wait for vpn to connect before continuing
while [ $(piactl get connectionstate) = "Disconnected" ]; do
      piactl connect;
done

# create header and body for email
SRV_NAME=$(hostname)
EVENT_TIME=$(date +%Y/%m/%d-%H:%M:%S)

# write time server completed reboot to logs and send notification
echo "$(hostname) reboot completed at $(date +%Y/%m/%d-%H:%M:%S)"
ntfy -t "$(hostname)" send "This is an automated message to notify you that $SRV_NAME restarted successfully at $EVENT_TIME."
