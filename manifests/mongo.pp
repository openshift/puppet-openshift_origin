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

  exec { 'start mongodb':
    command     => "${::openshift_origin::rm} -rf /var/log/mongodb/mongodb.log && \
     ${::openshift_origin::service} mongod restart ; \
     ${::openshift_origin::touch} /var/log/mongodb/mongodb.log && \
     ${::openshift_origin::chown} mongodb:mongodb /var/log/mongodb/mongodb.log ; \
     /bin/fgrep '[initandlisten] waiting for connections' /var/log/mongodb/mongodb.log ; \
     while [ ! $? -eq 0 ] ; \
       do sleep 2 ; \
       ${::openshift_origin::echo} '.' ; \
       /bin/fgrep '[initandlisten] waiting for connections' /var/log/mongodb/mongodb.log ; \
     done",
    refreshonly => true,
    subscribe   => File['Temporarily Disable mongo auth'],
    require     => [
      Package['mongodb'],
      Package['mongodb-server'],
    ],
  }

  exec { 'set mongo admin password':
    command     => "/usr/bin/mongo ${::ipaddress}/${::openshift_origin::mongo_db_name} --eval 'db.addUser(\"${::openshift_origin::mongo_auth_user}\", \"${::openshift_origin::mongo_auth_password}\")' && \
       /usr/bin/mongo ${::ipaddress}/admin --eval 'db.addUser(\"${::openshift_origin::mongo_auth_user}\", \"${::openshift_origin::mongo_auth_password}\")'",
    refreshonly => true,
    subscribe   => Exec['start mongodb'],
    notify      => Exec['re-enable mongo'],
    require     => [
      Package['mongodb'],
      Package['mongodb-server'],
    ],
  }

  if $::openshift_origin::broker_auth_plugin == 'mongo' {
    exec { 'create mongo auth plugin admin user':
      command     => "/usr/bin/mongo ${::ipaddress}/openshift_broker_dev --eval 'db.auth_user.update({\"_id\":\"admin\"}, {\"_id\":\"admin\",\"user\":\"admin\",\"password_hash\":\"2a8462d93a13e51387a5e607cbd1139f\"}, true)'",
      refreshonly => true,
      subscribe   => Exec['start mongodb'],
      notify      => Exec['re-enable mongo'],
      require     => [
        Package['mongodb'],
        Package['mongodb-server'],
      ],
    }
  }

  exec { 're-enable mongo':
    command     => "${::openshift_origin::echo} 'auth = true' >> /etc/mongodb.conf && \
      ${::openshift_origin::service} mongod restart",
    refreshonly => true,
    require     => [
      Package['mongodb'],
      Package['mongodb-server'],
    ],
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'mongod':
      require   => [Package['mongodb'], Package['mongodb-server']],
      enable    => true,
      subscribe => Exec['re-enable mongo'],
    }
  }

  if $::openshift_origin::configure_firewall == true {
    $mongo_port = $::use_firewalld ? {
      true    => '27017/tcp',
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
