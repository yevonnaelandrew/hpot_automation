#!/bin/bash
echo "Installing prerequsite"
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install wget curl nano git -y
echo "Begin installing docker"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo systemctl enable docker.service && sudo systemctl enable containerd.service
echo "Finished installing docker"
echo "Begin installing MongoDB"
wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt-get update && sudo apt-get install -y mongodb-org
sudo systemctl enable mongod && sudo systemctl start mongod
echo "Finished installing MongoDB"
sudo sed -i -e "s/#Port 22/Port 22888/g" /etc/ssh/sshd_config && sudo service sshd restart
git clone https://github.com/yevonnaelandrew/cowrie && cd cowrie
sudo docker build -t isif/cowrie:cowrie_hp -f docker/Dockerfile .
sudo docker volume create cowrie-var
sudo docker volume create cowrie-etc
sudo docker run -p 22:2222/tcp -p 23:2223/tcp -v cowrie-etc:/cowrie/cowrie-git/etc -v cowrie-var:/cowrie/cowrie-git/var -d --cap-drop=ALL --read-only isif/cowrie:cowrie_hp
cd ..
git clone https://github.com/yevonnaelandrew/dionaea && cd dionaea
sudo docker build -t isif/dionaea:dionaea_hp -f Dockerfile .
sudo docker run --rm -it -p 21:21 -p 42:42 -p 69:69/udp -p 80:80 -p 135:135 -p 443:443 -p 445:445 -p 1433:1433 -p 1723:1723 -p 1883:1883 -p 1900:1900/udp -p 3306:3306 -p 5060:5060 -p 5060:5060/udp -p 5061:5061 -p 11211:11211 -v dionaea:/opt/dionaea -d isif/dionaea:dionaea_hp
cd ..
git clone https://github.com/yevonnaelandrew/honeytrap && cd honeytrap
sudo bash dockerize.sh && sudo docker run -it -p 2222:2222 -p 8545:8545 -p 5900:5900 -p 25:25 -p 5037:5037 -p 631:631 -p 389:389 -p 6379:6379 -v honeytrap:/home -d honeytrap_test:latest
cd ..
sudo docker pull isif/rdpy:rdpy_hp
sudo mkdir /var/lib/docker/volumes/rdpy /var/lib/docker/volumes/rdpy/_data
sudo docker run -it -p 3389:3389 -v rdpy:/var/log -d isif/rdpy:rdpy_hp /bin/sh -c 'python /rdpy/bin/rdpy-rdphoneypot.py -l 3389 /rdpy/bin/1 >> /var/log/rdpy.log'
sudo docker pull isif/gridpot:gridpot_hp
sudo docker volume create gridpot
sudo docker run -it -p 102:102 -p 8000:80 -p 161:161 -p 502:502 -d -v gridpot:/gridpot isif/gridpot:gridpot_hp /bin/bash -c 'cd gridpot; gridlabd -D run_realtime=1 --server ./gridpot/gridlabd/3.1/models/IEEE_13_Node_With_Houses.glm; conpot -t gridpot'
sudo docker pull isif/elasticpot:elasticpot_hp
sudo mkdir /var/lib/docker/volumes/elasticpot /var/lib/docker/volumes/elasticpot/_data
sudo docker run -it -p 9200:9200/tcp -v elasticpot:/elasticpot/log -d isif/elasticpot:elasticpot_hp /bin/sh -c 'cd elasticpot; python3 elasticpot.py'
sudo apt-get install python3-pip -y
mkdir ewsposter_data ewsposter_data/log ewsposter_data/spool ewsposter_data/json
git clone --branch mongodb https://github.com/yevonnaelandrew/ewsposter && cd ewsposter
sudo pip3 install -r requirements.txt && sudo pip3 install influxdb
