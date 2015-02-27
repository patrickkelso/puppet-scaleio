
class scaleio::shm (
	$shm_size              = $scaleio::params::shm_size
){
	exec { 'shm': 
	  command => "mount -o remount -o size=${shm_size} /dev/shm",
	  path => ["/bin","/usr/bin"],
	  onlyif => [ "test `df -B1 /dev/shm | awk '/\/dev\/shm/ { print \$4; }'` -lt ${shm_size}" ],
	} ->
#	`cat /etc/fstab | grep "/dev/shm" | awk '{ print $4;}' | awk -F, '{ print $2}' | grep size | awk -F= '{ print $2}'` 
	file_line { 'Replace a line in fstab':
	    path => '/etc/fstab',  
	    match => "^tmpfs",
	    line => "tmpfs  /dev/shm  tmpfs defaults,size=${shm_size}  0 0",
	} ->
# The code below is failing for me using the Vagrant Box. Need to investigate.
# Puppet Open Source 3.7.4.
# Error: Could not retrieve catalog from remote server: Error 400 on SERVER: Evaluation Error: 
# Comparison of: String < Integer, is not possible. Caused by 'A String is not comparable to a 
# non String'. at /etc/puppet/modules/scaleio/manifests/shm.pp:16:22 on node tb.scaleio.local

# If I comment it out Everything works.

	if ($::kernelshmmax < 209715200) {
	    exec {'set kernel shmmax' :
	      command   => 'sysctl -p 209715200',
	      logoutput => true,
	      path      => '/sbin',
	    }
    } else { notify {'kernelshmmax set correctly':} } 
}
