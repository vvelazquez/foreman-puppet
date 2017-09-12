#!/bin/sh

# Update system first
sudo yum update -y


# Add agent section to /etc/puppet/puppet.conf
# Easier to set run interval to 120s for testing (reset to 30m for normal use)
# https://docs.puppetlabs.com/puppet/3.8/reference/config_about_settings.html
echo "" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
echo "    server = theforeman.example.com" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
echo "    runinterval = 120s" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null

sudo service puppet stop
#sudo service puppet start
sudo puppet resource service puppet ensure=running enable=true
sudo puppet agent --enable

# Unless you have Foreman autosign certs, each agent will hang on this step until you manually
# sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
# Alternative, run manually on each host, after provisioning is complete...
#sudo puppet agent --test --waitforcert=60
