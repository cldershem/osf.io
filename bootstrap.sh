export DEBIAN_FRONTEND="noninteractive"

# # update ubuntu
apt-get update
apt-get -y upgrade

# install prereqs
apt-get -y install python-dev python-pip git libxml2-dev libxslt-dev python-setuptools
apt-get -y build-dep python-lxml

# install tokumx
apt-key adv --keyserver keyserver.ubuntu.com --recv-key 505A7412
echo "deb [arch=amd64] http://s3.amazonaws.com/tokumx-debs $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tokumx.list
apt-get update
apt-get -y install tokumx

# setup venv
pip install virtualenvwrapper
echo "export WORKON_HOME=/home/vagrant/.venvs" >> /home/vagrant/.bashrc
echo "source /usr/local/bin/virtualenvwrapper.sh" >> /home/vagrant/.bashrc

export WORKON_HOME=/home/vagrant/.venvs
source /usr/local/bin/virtualenvwrapper.sh
mkdir -p $WORKON_HOME
chown -R vagrant:vagrant $WORKON_HOME
mkvirtualenv OSF
workon OSF

# install requirements
# pip install -r /vagrant/requirements/dev.txt
cd /vagrant/ && workon OSF && pip install invoke
cd /vagrant/ && workon OSF && inv requirements --dev
cd /vagrant/ && workon OSF && inv requirements --addons

# install rabbitmq
apt-key adv --keyserver pgp.mit.edu --recv-keys 0x056E8E56
echo "deb http://www.rabbitmq.com/debian/ testing main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list
apt-get update
apt-get -y install rabbitmq-server

# running rabbitmq
# cd /vagrant/ && workon OSF && invoke rabbitmq

# install eleasticsearch
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get -y install oracle-java8-installer
echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> /home/vagrant/.bashrc
source ~/.bashrc
wget --quiet https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.1.deb
sudo dpkg -i elasticsearch-1.2.1.deb
rm elasticsearch-1.2.1.deb

# install node, npm, and bower
apt-get -y install nodejs npm
ln -s /usr/bin/nodejs /usr/bin/node
npm install -g bower

# run
# rabbitmq
rabbitmq-server
# monogo
cd /vagrant/ && workon OSF && invoke mongo -d
# celery
cd /vagrant/ && workon OSF && invoke celery_worker
# elastic search
service elasticsearch start
# mail
cd /vagrant/ && workon OSF && invoke mailserver
# assets
cd /vagrant/ && workon OSF && invoke assets -dw
cd /vagrant/ && workon OSF && bower prune
cd /vagrant/ && workon OSF && bower install
cd /vagrant/ && workon OSF && npm install webpack
cd /vagrant/node_modeules/webpack/bin/ && ./webpack.js --config webpack.dev.config.js

# server
cd /vagrant/ && workon OSF && invoke server --host '0.0.0.0'

# # fake auth
# wget --quite https://github.com/CenterForOpenScience/fakecas/releases/download/0.2.0/fakecas
# chmod +x fakecas
# ./fakecas
