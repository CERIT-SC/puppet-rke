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

Facter.add("nvidiatoolkit") do
    setcode do
      if File.exists?('/usr/local/nvidia/toolkit/nvidia-container-runtime')
        "present"
      else
        "absent"
      end      
    end
end
