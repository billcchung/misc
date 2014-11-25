#! /bin/bash
# you can check /var/log/cloud-init-output.log for the outputs
# usually the whole shell script takes around 70s
# this script is only for Ubuntu or Redhat/Centos.
ACCESS_KEY_ID="<access key id>"
SECRET_ACCESS_KEY="<secret access key>"
KEYNAME="<key pair name>"
PRIVATE_KEY="<private key location>"
is_ubuntu=`grep 'Ubuntu' /proc/version`
is_redhat=`grep 'Red Hat' /proc/version` #also for centos 6
if [ "$is_ubuntu" ]; then

## install salt-master, salt-cloud and related stuff.
    sudo add-apt-repository ppa:saltstack/salt -y
    sudo apt-get update -y
    sudo apt-get install git -y
    sudo apt-get install salt-master -y
    sudo apt-get install python-libcloud -y
    sudo apt-get install salt-cloud -y
    sudo apt-get install smbclient -y
    wget -nc -q http://download.opensuse.org/repositories/home:/uibmz:/opsi:/opsi40-testing/xUbuntu_12.04/amd64/winexe_1.00.1-1_amd64.deb
    cloud_loc="/usr/lib/python2.`salt --versions-report | awk -F. '/Python/{print $2}'`/dist-packages/salt/utils/cloud.py"
    sudo dpkg -i winexe_1.00.1-1_amd64.deb
elif [ "$is_redhat" ]; then
    # The steps are for redhat 6
    sudo rpm -Uvh http://ftp.linux.ncsu.edu/pub/epel/6/i386/epel-release-6-8.noarch.rpm
    sudo yum -y install salt-master
    sudo yum -y install samba-client
    sudo yum -y install python-libcloud
    sudo yum -y install salt-cloud
    curl -O http://ftp5.gwdg.de/pub/opensuse/repositories/home:/uibmz:/opsi:/opsi40-testing/CentOS_CentOS-6/x86_64/winexe-1.00.1-10.2.x86_64.rpm
    sudo rpm -Uvh winexe-1.00.1-10.2.x86_64.rpm
    cloud_loc="/usr/lib/python2.`salt --versions-report | awk -F. '/Python/{print $2}'`/site-packages/salt/utils/cloud.py"
    sudo chkconfig salt-master on
fi
# update cloud.py

sudo mv -f cloud.py $cloud_loc



# edit salt master config
echo -e "\npeer:\n  .*:\n    - network.ip_addrs\n    - splunk.*\n" | sudo tee -a /etc/salt/master > /dev/null
echo -e "\npillar_roots:\n  base:\n    - /srv/salt/pillar\n" | sudo tee -a /etc/salt/master > /dev/null
echo -e "\nfile_recv: True\n" | sudo tee -a /etc/salt/master > /dev/null
echo -e "\ntimeout: 15\n" | sudo tee -a /etc/salt/master > /dev/null

# fetch splunk realted modules, states and other stuff.
mkdir ~/.ssh/
echo """-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAqhjhYPZcF4WwWyPLTFssLnovuF84B0qfNONrXCOnTnS0YOO7
NYPAcwYsnqfW849Hq28tkslbEELltWv3f1INkwyo0ZwE6WhNwfgcyNy49y5Cu6P6
+RSL0msRhF3fipiQKmY8vwO/zrZQ4Y/lj6smFalTMcT7stZXAdzHEQNY5S1Vfo4Z
0CbXD6rGUc/Jo6+2rje/iUHm8Z+EH5xkIXzX5PUab3VtSNZdHGOFjdtXSsfMDrdd
VDwk6rU/Hb3XEGMVomnm+4PyANHs0El8W1WRdk9f2H+0W6YkVDOEPHd3uUvmyt88
D22huFYDkw4OTQN5KoTSiVZe3il5TTDP7lASTwIDAQABAoIBAFehN8M/SFRp8GAT
wbGVqt5K3njKvU+sVvblTrMKPzBBGYhs6k54kNXxUV1vNGMH5rFgNodPqtVm0Xa0
p631NL8UH4jVKwagUKbkTtgANl5Je+G1ah+WQS5nMIAT6I07adIeF5+Eq/Uvod2C
x45LavRv5kdWpyEMIYj5F6khI1P1Pr+QjNgpI5UiAik+GW7UydgkSGPpuVL5jDIH
Mv5yTvvMDct/KDnLsjwRhvZ4b0fIDu49eMxuKw6JYETMsI2EAzIqxJRNgz2TFsKo
HSOP0p5Xpyhc0ty47Fzsb5xX0A6v6gCzAjAtNei29N3N8epcqboPIGV8oeQrRUZw
blmIShkCgYEA2pGUFL4/vUa+b4N+jqirzmASO3Ayyyt8bfKBpaCHRt3E7pxyhXnl
GREsh2cAdIfnAIXBYQJlzphZCVwiXQmLII6IPANLKV3KHvB6GivCMOdW4yfmRw5x
7gCx5UYt9EWqDNdxbyUBIhgoedvtVXACRMVWnceP2t7cEYcSErHLpgUCgYEAxzo6
5eyXLZKPvBKfu2bg/lriP+ycZQVb5EPuglGDxMTGWy++KMIm2XRA9KTFSxtSmXWf
gIRnVEL3BMAyhTGgQpzPVfq++mYJR7sTMXrWaR4bSS7zSF09+E3vVQ809HYoR5nY
KGERbWQTBLOUrBeqD5+UiGo87MsTElbSfllwU0MCgYBF7d3a5SOvgzraos+TBRQy
6znqGnOl3TvqUXR5cWrWmY2wag2Z9u39nykICUR0BCc8W48LYqEAAG48OGYmLi99
Mx0TVlpt2bwZOgdW6DkxPFLoSpO6mDyLUV2ZZWK+jKtjgGqijMxYBDKvClZcx4Fy
T1DvGjJEbJksYnK92HS3oQKBgAPmdO65YgBHZT72UmA11GPGXbWIqUsk/raKSeoN
NHouq/9vANcFbgNFzlu7ug0NXOGaNuQqM2en4/QY2yRWY1/KeBijzwdR5g6cb/TB
Bd+K8lfNbn/VK3hn9i6BHLVIduNn9J5dwByXH/Qwm9F+qRqjMiI1ijnMg/QQ9Q/6
KkPHAoGAe5oKcQKcbz1ipOZKB3V+nZSOK/gTxvAsRjj5uGcmCPIMvh4/Q6e828Ss
00R+TTSu4s3zU0AdR8FfeBDt7QUZYyRi4Ffdj0LxwyrSaM5zRN1UeHGvFmZata9Q
uQ9uXqcY8tDDphSDttld3FwtLd1vH64jL/FASKjZX67EkzPeKvM=
-----END RSA PRIVATE KEY-----""" | sudo tee /root/.ssh/id_rsa_bitbucket > /dev/null
echo -e "Host bitbucket.org\n\tHostName bitbucket.org\n\tUser git\n\tIdentityFile ~/.ssh/id_rsa_bitbucket\n\tStrictHostKeyChecking no\n" | sudo tee -a /root/.ssh/config > /dev/null
sudo chmod 400 /root/.ssh/id_rsa_bitbucket
sudo git clone git@bitbucket.org:splunksusqa/salt.git /srv/salt
sudo sed -i "s/salt-master/`hostname -I`/" /srv/salt/cloud/cloud.profiles
sudo sed -i "/^  id/ s/:.*/: $ACCESS_KEY_ID/" /srv/salt/cloud/cloud.providers
sudo sed -i "/^  key:/ s/:.*/: $SECRET_ACCESS_KEY/" /srv/salt/cloud/cloud.providers
sudo sed -i "/^  keyname:/ s/:.*/: $KEYNAME/" /srv/salt/cloud/cloud.providers
sudo sed -i "/^  private_key:/ s/:.*/: $PRIVATE_KEY/" /srv/salt/cloud/cloud.providers
sudo cp /srv/salt/cloud/* /etc/salt/
sudo service salt-master restart