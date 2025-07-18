#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

# Create .bashrc with default content
mkdir -p $HOME
cat > $HOME/.bashrc << EOF
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# NSS Wrapper configuration
USER_ID=\$(id -u)
GROUP_ID=\$(id -g)

if [ x"\$USER_ID" != x"0" ]; then
    NSS_WRAPPER_PASSWD=/tmp/passwd
    NSS_WRAPPER_GROUP=/etc/group

    cat /etc/passwd > \$NSS_WRAPPER_PASSWD
    echo "default:x:\${USER_ID}:\${GROUP_ID}:Default Application User:\${HOME}:/bin/bash" >> \$NSS_WRAPPER_PASSWD

    export NSS_WRAPPER_PASSWD
    export NSS_WRAPPER_GROUP

    if [ -r /usr/lib/x86_64-linux-gnu/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
    elif [ -r /usr/lib/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib/libnss_wrapper.so
    elif [ -r /usr/lib64/libnss_wrapper.so ]; then
        export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
    else
        echo "no libnss_wrapper.so installed!"
        exit 1
    fi
fi
EOF

# Set proper permissions
chmod 644 $HOME/.bashrc
