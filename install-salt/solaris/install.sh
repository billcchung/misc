#!/bin/bash
salt-master=$1
pkgadd -d http://get.opencsw.org/now

echo "mirror=http://mirror.opencsw.org/opencsw/unstable" >> /etc/opt/csw/pkgutil.conf
export

/opt/csw/bin/pkgutil -U
/opt/csw/bin/pkgutil -i -y python py_yaml py_pyzmq py_jinja2 py_msgpack_python py_m2crypto py_crypto libssl1_0_0 git vim python_dev


mkdir /etc/salt/
curl -k -o /etc/salt/minion -O https://raw.githubusercontent.com/saltstack/salt/develop/conf/minion
echo -e "master: $salt-master \nid: $(check-hostname | awk '{ print $NF }')" >> /etc/salt/minion
