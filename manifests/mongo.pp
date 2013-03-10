# == Class: openshift_origin::mongo
#
# Manage MongoDB for OpenShift Origin.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::mongo
#
# === Copyright
#
# Copyright 2013 Mojo Lingo LLC.
# Copyright 2013 Red Hat, Inc.
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
class openshift_origin::mongo {
  include openshift_origin::params
  ensure_resource('package', 'mongodb', {
      ensure  => present,
      require => Yumrepo['openshift-origin-deps'],
    }
  )
  ensure_resource('package', 'mongodb-server', {
      ensure  => present,
      require => Yumrepo['openshift-origin-deps'],
    }
  )

  file { 'Temporarily Disable mongo auth':
    ensure  => present,
    path    => '/etc/mongodb.conf',
    content => template('openshift_origin/mongodb/mongodb.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [
      Package['mongodb'],
      Package['mongodb-server'],
    ],
  }
  
  file { 'mongo setup script':
    ensure  => present,
    path    => '/usr/sbin/oo-mongo-setup',
    content => template('openshift_origin/mongodb/oo-mongo-setup'),
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => [
      Package['mongodb'],
      Package['mongodb-server'],
    ],
  }

  if $openshift_origin::configure_mongodb == 'delayed' {
    $openshift_init_provider = $::operatingsystem ? {
      'Fedora' => 'systemd',
      'CentOS' => 'redhat',
      default  => 'redhat',
    }
    
    if $openshift_init_provider == 'systemd' {
      file { 'mongo setup service':
        ensure  => present,
        path    => '/usr/lib/systemd/system/openshift-mongo-setup.service',
        content => template('openshift_origin/mongodb/openshift-mongo-setup.service'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => [
          File['mongo setup script']
        ],
      }      
    } else {
      fail "Delayed mongo setup for RHEL not available"
    }

    service { ['openshift-mongo-setup']:
      require  => [
        File['mongo setup script'],
        File['mongo setup service'],
      ],
      provider => $openshift_init_provider,
      enable   => true,
    }
  } else {
    exec { '/usr/sbin/oo-mongo-setup':
      require => File['mongo setup script']
    }
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'mongod':
      require   => [Package['mongodb'], Package['mongodb-server']],
      enable    => true,
    }
  }

  if $::openshift_origin::configure_firewall == true {
    $mongo_port = $::use_firewalld ? {
      'true'  => '27017/tcp',
      default => '27017:tcp',
    }

    exec { 'Open port for MongoDB':
      command => "${openshift_origin::params::firewall_port_cmd}${mongo_port}",
      require => [
        Package['mongodb'],
        Package['mongodb-server'],
        Package['firewall-package'],
      ],
    }
  }
}
