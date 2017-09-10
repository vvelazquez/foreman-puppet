#!/bin/sh


echo "@@bootstrap-foreman ... starting"

echo "@@bootstrap-foreman ... Update system first: yum update -y "
sudo yum update -y


echo "@@bootstrap-foreman ... puppet checks "
if puppet agent --version | grep "4." | grep -v grep 2> /dev/null
then
    echo "@@bootstrap-foreman ... Puppet Agent $(puppet agent --version) is already installed. A la verga de aqui..."
else
    echo "@@bootstrap-foreman ... Puppet Agent $(puppet agent --version) installed. Replacing..."

	echo "@@bootstrap-foreman ...  sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm"
    sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
	echo "@@bootstrap-foreman ...  yum -y install puppetserver puppetdb"
	sudo yum -y install puppetserver puppetdb
	
	echo "@@bootstrap-foreman ...  sudo yum -y erase puppet-agent "
    sudo yum -y erase puppet-agent && \
	
	echo "@@bootstrap-foreman ...  sudo rm -f /etc/yum.repos.d/puppetlabs-pc1.repo"
    sudo rm -f /etc/yum.repos.d/puppetlabs-pc1.repo && \
	
	echo "@@bootstrap-foreman ...  sudo yum clean all"
    sudo yum clean all
fi





if ps aux | grep "/usr/share/foreman" | grep -v grep 2> /dev/null
then
    echo "@@bootstrap-foreman ... Foreman appears to all already be installed. Exiting..."
else
	echo "@@bootstrap-foreman ... Installing foreman... starting"
	
	echo "@@bootstrap-foreman ... Installing foreman... sudo yum -y install epel-release http://yum.theforeman.org/releases/1.15/el7/x86_64/foreman-release.rpm "
    sudo yum -y install epel-release http://yum.theforeman.org/releases/1.15/el7/x86_64/foreman-release.rpm && \
	                                 
	echo "@@bootstrap-foreman ... Installing foreman... sudo yum -y install foreman-installer && \ "
    sudo yum -y install foreman-installer && \
	
	echo "@@bootstrap-foreman ... Before foreman-installer..."
    sudo foreman-installer
	echo "@@bootstrap-foreman ... After foreman-installer..."
	echo "@@bootstrap-foreman ... Installing foreman... ending"


    # 
	echo "@@bootstrap-foreman ... Set-up firewall... starting"	
    # https://www.digitalocean.com/community/tutorials/additional-recommended-steps-for-new-centos-7-servers
	
	echo "@@bootstrap-foreman ... Set-up firewall - add-port... starting"
    sudo firewall-cmd --permanent --add-service=http
    sudo firewall-cmd --permanent --add-service=https
    sudo firewall-cmd --permanent --add-port=69/tcp
    sudo firewall-cmd --permanent --add-port=67-69/udp
    sudo firewall-cmd --permanent --add-port=53/tcp
    sudo firewall-cmd --permanent --add-port=53/udp
    sudo firewall-cmd --permanent --add-port=8443/tcp
    sudo firewall-cmd --permanent --add-port=8140/tcp
	echo "@@bootstrap-foreman ... Set-up firewall - add-port... ending"

	echo "@@bootstrap-foreman ... Set-up firewall - firewall-cmd --reload"
    sudo firewall-cmd --reload
	
	echo "@@bootstrap-foreman ... Set-up firewall - systemctl enable firewalld"
    sudo systemctl enable firewalld
	echo "@@bootstrap-foreman ... Set-up firewall... ending"

    # First run the Puppet agent on the Foreman host which will send the first Puppet report to Foreman,
    # automatically creating the host in Foreman's database
	
	echo "@@bootstrap-foreman ... ... run the Puppet agent on the Foreman host"
    sudo puppet agent --test --waitforcert=60

    # Optional, install some optional puppet modules on Foreman server to get started...
		# echo "... install some optional puppet modules"
		# sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-ntp
		# sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-git
		# sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-vcsrepo
		# sudo puppet module install -i /etc/puppet/environments/production/modules garethr-docker
		# sudo puppet module install -i /etc/puppet/environments/production/modules jfryman-nginx
		# sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-haproxy
		# sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-apache
		# sudo puppet module install -i /etc/puppet/environments/production/modules puppetlabs-java
fi


echo "@@bootstrap-foreman ... ending"
