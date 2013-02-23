package { 'bind':
  ensure => present,
}

exec { 'generate tsig key':
  command => "/usr/bin/rm -rf /var/named/Kexample.com* ; \
              /usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named example.com",
  require => Package['bind'],
}

augeas{ 'network setup' :
  context => '/files/etc/sysconfig/network-scripts/ifcfg-eth0',
  changes => [
    'set PEERDNS no',
  ],
}
