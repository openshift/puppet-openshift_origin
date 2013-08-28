package { 'bind':
  ensure => present,
}

exec { 'generate tsig key':
  command => "/usr/bin/env rm -rf /var/named/Kexample.com* ; \
              /usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named example.com",
  require => Package['bind'],
}

$dev='p2p1'
augeas{ 'network setup' :
  context => "/files/etc/sysconfig/network-scripts/ifcfg-${dev}",
  changes => [
    "set NAME ${dev}",
    'set ONBOOT yes',
    'set TYPE Ethernet',
    'set BOOTPROTO dhcp',
    'set PEERDNS no',
    'set DNS1 8.8.8.8',
  ],
}
