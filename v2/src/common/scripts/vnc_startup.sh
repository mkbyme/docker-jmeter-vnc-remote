#!/bin/bash
### every exit != 0 fails the script
set -e

## print out help
help (){
echo "
USAGE:
docker run -it -p 6901:6901 -p 5901:5901 mkbyme/<image>:<tag> <option>

IMAGES:
mkbyme/docker-jmeter-vnc-remote:<tag>

OPTIONS:
-w, --wait      (default) keeps the UI and the vncserver up until SIGINT or SIGTERM will received
-s, --skip      skip the vnc startup and just execute the assigned command.
                example: docker run mkbyme/docker-jmeter-vnc-remote --skip bash
-d, --debug     enables more detailed startup output
                e.g. 'docker run mkbyme/docker-jmeter-vnc-remote --debug bash'
-h, --help      print out this help
"
}
if [[ $1 =~ -h|--help ]]; then
    help
    exit 0
fi

# Source the .bashrc which already contains our environment setup
[[ -f "$HOME/.bashrc" ]] && source $HOME/.bashrc

# add `--skip` to startup args, to skip the VNC startup procedure
if [[ $1 =~ -s|--skip ]]; then
    echo -e "\n\n------------------ SKIP VNC STARTUP -----------------"
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${@:2}'"
    exec "${@:2}"
fi
if [[ $1 =~ -d|--debug ]]; then
    echo -e "\n\n------------------ DEBUG VNC STARTUP -----------------"
    export DEBUG=true
fi

## correct forwarding of shutdown signal
cleanup () {
    echo "Cleaning up..."
    kill -s SIGTERM $!
    pkill -f Xtigervnc
    pkill -f xfwm4
    pkill -f xfdesktop
    rm -rf /tmp/.X*-lock /tmp/.X11-unix/*
    exit 0
}
trap cleanup SIGINT SIGTERM

## Kill any existing VNC/X processes
echo -e "\n------------------ Cleanup existing processes ------------------"
pkill -f Xtigervnc || true
pkill -f xfwm4 || true
pkill -f xfdesktop || true
rm -rf /tmp/.X*-lock /tmp/.X11-unix/*

## resolve_vnc_connection
VNC_IP=$(hostname -i)

## change vnc password
echo -e "\n------------------ change VNC password  ------------------"
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.vnc/passwd"

if [[ -f $PASSWD_PATH ]]; then
    echo -e "\n---------  purging existing VNC password settings  ---------"
    rm -f $PASSWD_PATH
fi

if [[ $VNC_VIEW_ONLY == "true" ]]; then
    echo "start VNC server in VIEW ONLY mode!"
    #create random pw to prevent access
    echo $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20) | tigervncpasswd -f > $PASSWD_PATH
fi
echo "$VNC_PW" | tigervncpasswd -f >> $PASSWD_PATH
chmod 600 $PASSWD_PATH

## Start VNC server
echo -e "\n------------------ start VNC server ------------------------"
echo "remove old vnc locks to be a reattachable container"
vncserver -kill $DISPLAY &> $STARTUPDIR/vnc_startup.log \
    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &> $STARTUPDIR/vnc_startup.log \
    || echo "no locks present"

echo -e "start vncserver with param: VNC_COL_DEPTH=$VNC_COL_DEPTH, VNC_RESOLUTION=$VNC_RESOLUTION\n..."
if [[ $DEBUG == true ]]; then echo "vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION"; fi
vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION &> $STARTUPDIR/no_vnc_startup.log

# Wait for VNC to start properly
sleep 2

# Start window manager
echo -e "start window manager\n..."
$HOME/wm_startup.sh &> $STARTUPDIR/wm_startup.log

## Start noVNC
echo -e "\n------------------ start noVNC  ----------------------------"
if [[ $DEBUG == true ]]; then echo "$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT"; fi
cd $NO_VNC_HOME
./utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &> $STARTUPDIR/no_vnc_startup.log &
PID_SUB=$!

## log connect options
echo -e "\n\n------------------ VNC environment started ------------------"
echo -e "\nVNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"
echo -e "\nnoVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"

if [[ $DEBUG == true ]] || [[ $1 =~ -t|--tail-log ]]; then
    echo -e "\n------------------ $HOME/.vnc/*$DISPLAY.log ------------------"
    # if option `-t` or `--tail-log` block the execution and tail the VNC log
    tail -f $STARTUPDIR/*.log $HOME/.vnc/*$DISPLAY.log
fi

if [ -z "$1" ] || [[ $1 =~ -w|--wait ]]; then
    wait $PID_SUB
else
    # unknown option ==> call command
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '$@'"
    exec "$@"
fi
