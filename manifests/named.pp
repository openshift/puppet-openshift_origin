class openshift_origin::named{
  if $::openshift_origin::named_tsig_priv_key == '' {
    warning "Generate the Key file with '/usr/sbin/dnssec-keygen -a HMAC-MD5 -b 512 -n USER -r /dev/urandom -K /var/named ${cloud_domain}'"
    warning "Use the last field in the generated key file /var/named/K${cloud_domain}*.key"
    fail 'named_tsig_priv_key is required.'
  }

  package { ['bind', 'bind-utils']:
    ensure => present,
  }

  file { 'dynamic zone':
    path    => "/var/named/dynamic/${::openshift_origin::cloud_domain}.db",
    content => template('openshift_origin/named/dynamic-zone.db.erb'),
    owner   => 'named',
    group   => 'named',
    mode    => '0644',
    require => File['/var/named'],
  }

  exec { 'create rndc.key':
    command => '/usr/sbin/rndc-confgen -a -r /dev/urandom',
    unless  => '/usr/bin/[ -f /etc/rndc.key ]',
    require => Package['bind']
  }

  file { '/etc/rndc.key':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    require => Exec['create rndc.key'],
  }

  file { '/var/named/forwarders.conf':
    owner   => 'root',
    group   => 'named',
    mode    => '0640',
    content => template('openshift_origin/named/forwarders.conf.erb'),
  }

  file { '/var/named':
    ensure  => directory,
    owner   => 'named',
    group   => 'named',
    mode    => '0750',
    require => Package['bind']
  }

  file { '/var/named/dynamic':
    ensure  => directory,
    owner   => 'named',
    group   => 'named',
    mode    => '0750',
    require => File['/var/named'],
  }

  file { 'named key':
    path    => "/var/named/${::openshift_origin::cloud_domain}.key",
    content => template('openshift_origin/named/named.key.erb'),
    owner   => 'named',
    group   => 'named',
    mode    => '0444',
    require => File['/var/named'],
  }

  file { 'Named configs':
    path    => '/etc/named.conf',
    owner   => 'root',
    group   => 'named',
    mode    => '0644',
    content => template('openshift_origin/named/named.conf.erb'),
    require => Package['bind']
  }

  if $::openshift_origin::configure_firewall == true {
    exec { 'Open TCP port for BIND':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-port=53/tcp",
        default => "/usr/sbin/lokkit --port=53:tcp",
      },
      require => Package['firewall-package']
    }
    exec { 'Open UDP port for BIND':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-port=53/udp",
        default => "/usr/sbin/lokkit --port=53:udp",
      },
      require => Package['firewall-package']
    }
  }
  
  selboolean { ['named_write_master_zones'] :
    persistent => true,
    value      => 'on'
  }

  exec { 'named restorecon':
    command => '/sbin/restorecon -rv /etc/rndc.* /etc/named.* /var/named /var/named/forwarders.conf',
    require => [
      File['/etc/rndc.key'],
      File['/var/named/forwarders.conf'],
      File['/etc/named.conf'],
      File['/var/named'],
      File['/var/named/dynamic'],
      File['dynamic zone'],
      File['named key'],
      File['Named configs'],
      Exec['create rndc.key'],
    ],
  }

  service { 'named':
    ensure    => running,
    subscribe => File['/etc/named.conf'],
    enable    => true,
    require   => Exec['named restorecon']
  }
}
