#!/bin/bash

# yes, this is terrible
echo "puppetlabs" | /usr/local/bin/puppet access login --username admin --lifetime 1y

# deploy the Puppet code
/usr/local/bin/puppet code deploy production --wait

# Make sure the console is refreshed. The call returns instantly, we'll wait an arbitrary
# amount of time for it to possibly succeed.
echo "Refreshing Code on Puppet Master"
puppet node_manager classes --update
echo "Sleeping while NC service reads new code"
sleep 20

# Create some initial classifications in PE

/usr/local/bin/puppet apply << PE_GROUPS
node_group { 'master':
  ensure               => 'present',
  classes              => {'role::master' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['or', ['=', 'name', 'master.puppet.vm']],
}

node_group { 'jenkins':
  ensure               => 'present',
  classes              => {'role::jenkins' => {}},
  environment          => 'production',
  override_environment => false,
  parent               => 'All Nodes',
  rule                 => ['or', ['=', 'name', 'jenkins.puppet.vm']],
}
PE_GROUPS
