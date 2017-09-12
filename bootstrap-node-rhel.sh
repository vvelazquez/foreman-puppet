#!/bin/sh

echo "@@bootstrap-node-rhel. ... Update system first"
# Update system first
sudo yum update -y


# Add agent section to /etc/puppetlabs/puppet/puppet.conf
# Easier to set run interval to 120s for testing (reset to 30m for normal use)
# https://docs.puppetlabs.com/puppet/3.8/reference/config_about_settings.html
echo "@@bootstrap-node-rhel. ... Add agent section to /etc/puppetlabs/puppet/puppet.conf"
echo "" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
echo "    server = theforeman.example.com" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null && \
echo "    runinterval = 120s" | sudo tee --append /etc/puppetlabs/puppet/puppet.conf 2> /dev/null

echo "@@bootstrap-node-rhel. ... sudo service puppet stop"
sudo service puppet stop
#sudo service puppet start

echo "@@bootstrap-node-rhel. ... sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true"
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

echo "@@bootstrap-node-rhel. ... sudo /opt/puppetlabs/bin/puppet agent --enable"
sudo /opt/puppetlabs/bin/puppet agent --enable

# Unless you have Foreman autosign certs, each agent will hang on this step until you manually
# sign each cert in the Foreman UI (Infrastrucutre -> Smart Proxies -> Certificates -> Sign)
# Alternative, run manually on each host, after provisioning is complete...
#sudo puppet agent --test --waitforcert=60
