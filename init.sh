if [ -z $(which docker) ]; then
	# Install docker
	sudo apt-get update
	sudo apt-get install \
	    apt-transport-https \
	    ca-certificates \
	    curl \
	    software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository \
	   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	   $(lsb_release -cs) \
	   stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce=17.09.0~ce-0~ubuntu 
	sudo usermod -aG docker $USER
	echo 'Please logout and then log back in.'	
	exit
fi

if [ -z $(ls /usr/local/bin/docker-compose) ]; then
	# Install docker-compose
	sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
fi

cd reverse-proxy && sh start-reverse-proxy.sh

cd db && docker-compose up -d; cd ..
cd cache && sh start-cache.sh; cd ..
cd frontend && sh start-frontend-pro.sh; cd ..
cd master && sh start-master-pro.sh; cd ..

# Update the current default.conf to use the  master's ip addr
cd load-balancer
sh start-load-balancer.sh; cd ..
