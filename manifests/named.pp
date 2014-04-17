# Copyright 2013 Mojo Lingo LLC.
# Modifications by Red Hat, Inc.
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
class openshift_origin::named {
  include openshift_origin::params

  package { ['bind', 'bind-utils']:
    ensure  => present,
    require => Class['openshift_origin::install_method'],
  }

  if ! $::openshift_origin::named_ha or $::openshift_origin::named_ha and $::openshift_origin::named_master {
    file { '/var/named/dynamic':
      ensure  => directory,
      owner   => 'named',
      group   => 'named',
      mode    => '0750',
      require => File['/var/named'],
    }
    file { 'dynamic zone':
      ensure  => present,
      path    => "/var/named/dynamic/${openshift_origin::domain}.db",
      content => template('openshift_origin/named/dynamic-zone.db.erb'),
      owner   => 'named',
      group   => 'named',
      mode    => '0644',
      require => File['/var/named/dynamic'],
    }
    exec { 'zone-reload':
      path        => ['/bin/', '/usr/bin/', '/usr/sbin/'],
      command     => "rndc freeze ${openshift_origin::domain}; rndc reload ${openshift_origin::domain}; rndc thaw ${openshift_origin::domain}",
      refreshonly => true,
      subscribe   => File['dynamic zone'],
      require     => [File['/etc/rndc.key'],Service['named']],
    }
  }

  exec { 'create rndc.key':
    command => '/usr/sbin/rndc-confgen -a -r /dev/urandom',
    unless  => '/usr/bin/[ -f /etc/rndc.key ]',
    require => Package['bind'],
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
    owner   => 'root',
    group   => 'named',
    mode    => '0750',
    require => Package['bind'],
  }

  if $::openshift_origin::named_ha and ! $::openshift_origin::named_master {
    file { '/var/named/slaves':
      ensure  => directory,
      owner   => 'named',
      group   => 'named',
      mode    => '0770',
      require => File['/var/named'],
    }
  }

  file { 'named key':
    path    => "/var/named/${openshift_origin::domain}.key",
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
    require => Package['bind'],
  }

  # create named/adddress mappings for infrastructure hosts
  if $::openshift_origin::dns_infrastructure_zone != '' {

    file { 'infrastructure host configuration':
      path    => '/var/named/oo_infrastructure.conf',
      owner   => 'root',
      group   => 'named',
      mode    => '644',
      content => template('openshift_origin/named/oo_infrastructure.conf.erb'),
      notify  => Service['named'],
      require => File['/var/named'],
    }

    file { 'named infrastructure key':
      path    => "/var/named/${openshift_origin::dns_infrastructure_zone}.key",
      content => template('openshift_origin/named/oo_infrastructure_key.erb'),
      owner   => 'named',
      group   => 'named',
      mode    => '0444',
      require => File['/var/named'],
    }

    if ! $::openshift_origin::named_ha or $::openshift_origin::named_ha and $::openshift_origin::named_master {
      file { 'infrastructure zone contents':
        path    => "/var/named/dynamic/${openshift_origin::dns_infrastructure_zone}.db",
        owner   => 'named',
        group   => 'named',
        mode    => '664',
        content => template('openshift_origin/named/oo_infrastructure.db.erb'),
        require => File['infrastructure host configuration'],
      }
      exec { 'infrastructure-zone-reload':
        path        => ['/bin/', '/usr/bin/', '/usr/sbin/'],
        command     => "rndc freeze ${openshift_origin::dns_infrastructure_zone}; rndc reload ${openshift_origin::dns_infrastructure_zone}; rndc thaw ${openshift_origin::dns_infrastructure_zone}",
        refreshonly => true,
        subscribe   => File['infrastructure zone contents'],
        require     => [File['/etc/rndc.key'],Service['named']],
      }
    }
  } else {
  
    file { 'infrastructure host configuration (empty)':
      ensure  => present,
      path    => '/var/named/oo_infrastructure.conf',
      owner   => 'root',
      group   => 'named',
      mode    => '644',
      content => '// no openshift infrastructure zone',
      require => File['/var/named']
    }
  
  }
  
  firewall{ 'dns-tcp':
    port     => 53,
    protocol => 'tcp',
  }

  firewall{ 'dns-udp':
    port     => 53,
    protocol => 'udp',
  }

  if $::openshift_origin::named_ha and ! $::openshift_origin::named_master {
    $restorecon_files_real = [
                              '/etc/rndc.key',
                              '/var/named/forwarders.conf',
                              '/etc/named.conf',
                              '/var/named',
                              '/var/named/slaves',
                              'named key',
                              'Named configs',
                             ]
  } else {
    $restorecon_files_real = [
                              '/etc/rndc.key',
                              '/var/named/forwarders.conf',
                              '/etc/named.conf',
                              '/var/named',
                              '/var/named/dynamic',
                              'dynamic zone',
                              'named key',
                              'Named configs',
                             ]
  }

  exec { 'named restorecon':
    command => '/sbin/restorecon -rv /etc/rndc.* /etc/named.* /var/named /var/named/forwarders.conf',
    require => [File[$restorecon_files_real],Exec['create rndc.key']],
  }

  service { 'named':
    ensure     => running,
    subscribe  => File['/etc/named.conf'],
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Exec['named restorecon'],
  }
}
