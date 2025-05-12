class rke::priority (
   Optional[Array] $processes = $rke::params::priority_processes,
   String          $priority  = $rke::params::priority,
) inherits rke::params {

   if $processes != undef {
      $processes.each |String $_process| {
        exec{"renice ${_process}":
           command => "/bin/bash -c 'for i in `pgrep -u 0,998 ${_process}`; do renice ${priority} -p \$i; ls /proc/\$i/task | xargs renice ${priority}; done'",
           unless  => "/bin/bash -c 'for i in `pgrep -u 0,998 ${_process}`; do ps -o nice -p \$i | grep -q -e ${priority} || exit 1; done'",
        }
      }
   }       
}
