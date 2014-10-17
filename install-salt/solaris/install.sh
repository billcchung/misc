#!/bin/bash
# $1 for salt-maser, run as root
salt-master=$1

# install salt
pkgadd -d http://get.opencsw.org/now
echo "mirror=http://mirror.opencsw.org/opencsw/unstable" >> /etc/opt/csw/pkgutil.conf
/opt/csw/bin/pkgutil -U
/opt/csw/bin/pkgutil -i -y python py_yaml py_pyzmq py_jinja2 py_msgpack_python py_m2crypto py_crypto libssl1_0_0 git vim python_dev
echo "export PATH=/opt/csw/bin:/usr/local/bin/:$PATH:/usr/sfw/bin/:/usr/ccs/bin/" >> ~/.bashrc
echo "export PYTHONPATH=$PYTHONPATH:/opt/csw/lib/python2.6/site-packages/psutil-2.1.3-py2.6-solaris-2.10-i86pc.egg" >> ~/.bashrc
source ~/.bashrc
git clone clone https://github.com/saltstack/salt /opt/salt
python /opt/salt/setup.py install

# salt-minion settings
mkdir /etc/salt/
curl -k -o /etc/salt/minion -O https://raw.githubusercontent.com/saltstack/salt/develop/conf/minion
echo -e "master: $salt-master \nid: $(check-hostname | awk '{ print $NF }')" >> /etc/salt/minion

# start salt on boot
