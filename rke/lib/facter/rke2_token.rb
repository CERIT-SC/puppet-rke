# Fact: openstack_subnet
#
# Purpose:
#   List OpenStack subnet IDs of elixir-tesk project.
#
# Caveats:
#   Works only on machine with kubectl installed and openstack cli.
# 
# Resolution:
#   Returns hash of openstack subnet IDs which map to kuberentes cluster
#   If kubectl is not installed or openstack cli is missing, return nil
#
require 'json'

Facter.add("rke2token") do
    setcode do
      if File.exists?('/var/lib/rancher/rke2/server/node-token')
        File.read('/var/lib/rancher/rke2/server/node-token').chomp
      else
        nil
      end      
    end
end
