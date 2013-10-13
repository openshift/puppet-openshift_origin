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
class openshift_origin::mongo {
  ensure_resource('package', ['mongodb', 'mongodb-server'], {
      ensure  => present,
      require => Class['openshift_origin::install_method'],
    }
  )

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
    $cmd = $::operatingsystem ? {
      'Fedora' => '/usr/sbin/oo-mongo-setup',
      default => '/usr/bin/scl enable ruby193 /usr/sbin/oo-mongo-setup',
    }

    exec { '/usr/sbin/oo-mongo-setup':
      command => $cmd,
      require => [File['mongo setup script'],Class['openshift_origin::update_resolv_conf']]
    }
  }

  service { 'mongod':
    require   => [Package['mongodb'], Package['mongodb-server']],
    enable    => true,
  }
  
  firewall{ 'mongo-firewall':
    port      => '27017',
    protocol  => 'tcp',
  }
}
