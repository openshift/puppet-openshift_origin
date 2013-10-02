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
    ensure => present,
  }

  file { 'dynamic zone':
    path    => "/var/named/dynamic/${openshift_origin::domain}.db",
    content => template('openshift_origin/named/dynamic-zone.db.erb'),
    owner   => 'named',
    group   => 'named',
    mode    => '0644',
    require => File['/var/named/dynamic'],
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

  file { '/var/named/dynamic':
    ensure  => directory,
    owner   => 'named',
    group   => 'named',
    mode    => '0750',
    require => File['/var/named'],
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

  firewall{ 'dns':
    service => 'dns',
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
    require   => Exec['named restorecon'],
  }
}
