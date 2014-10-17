#!/bin/bash
# $1 for salt-master
salt-master=$1

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)”

brew install saltstack
brew install swig
brew install zmq
sudo pip install salt
sudo pip install psutil
sudo pip install --upgrade setuptools

mkdir /etc/salt/
curl -k -o /etc/salt/minion -O https://raw.githubusercontent.com/saltstack/salt/develop/conf/minion
echo -e "master: $salt-master \nid: $(hostname -f)" >> /etc/salt/minion

echo """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.saltstack.salt-minion</string>

    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python</string>
        <string>/usr/local/bin/salt-minion</string>
        <string>--log-level=info</string>
    </array>

    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
""" > /System/Library/LaunchDaemons/org.saltstack.salt-minion.plist

launchctl load /System/Library/LaunchDaemons/org.saltstack.salt-minion.plist

