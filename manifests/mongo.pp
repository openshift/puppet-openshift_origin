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

  $port = $openshift_origin::mongodb_port

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
      require => [File['mongo setup script'],Class['openshift_origin::update_conf_files']]
    }
  }

  if $openshift_origin::mongodb_replicasets {
    file { $openshift_origin::mongodb_keyfile:
      content => inline_template($openshift_origin::mongodb_key),
      owner   => $openshift_origin::params::user,
      group   => $openshift_origin::params::group,
      mode    => '0400',
      require => Exec['/usr/sbin/oo-mongo-setup'],
      notify  => Service['mongod'],
    }
    exec { 'keyfile-mongo-conf':
      path    => ['/bin/', '/usr/bin/', '/usr/sbin/'],
      command => "echo -e \"\nkeyFile = $openshift_origin::mongodb_keyfile\n\" >> /etc/mongodb.conf",
      unless  => "grep \"keyFile = $openshift_origin::mongodb_keyfile\" /etc/mongodb.conf",
      require => File[$openshift_origin::mongodb_keyfile],
      notify  => Service['mongod'],
    }
    exec { 'replset-mongo-conf':
      path    => ['/bin/', '/usr/bin/', '/usr/sbin/'],
      command => "echo -e \"\nreplSet = $openshift_origin::mongodb_replica_name\n\" >> /etc/mongodb.conf",
      unless  => "grep \"replSet = $openshift_origin::mongodb_replica_name\" /etc/mongodb.conf",
      require => [File[$openshift_origin::mongodb_keyfile],Exec['/usr/sbin/oo-mongo-setup']],
      notify  => Service['mongod'],
    }
    if $openshift_origin::mongodb_replica_primary {
      exec { 'replset-init':
        path    => ['/bin/', '/usr/bin/', '/usr/sbin/'],
        command => "mongo admin -u $openshift_origin::mongodb_admin_user -p $openshift_origin::mongodb_admin_password --quiet --eval printjson\"(rs.initiate({ _id: \'$openshift_origin::mongodb_replica_name\', members: [ { _id: 0, host: \'${ipaddress}:${port}\' } ] }))\"",
        unless  => "mongo admin --host $ipaddress -u $openshift_origin::mongodb_admin_user -p $openshift_origin::mongodb_admin_password --quiet --eval \"printjson(rs.status())\" | grep '\"name\" : \"${ipaddress}:${port}\"'",
        require => [Service['mongod'], Exec['keyfile-mongo-conf', 'replset-mongo-conf']],
      }
    } else {
      exec { 'replset-add':
        path    => ['/bin/', '/usr/bin/', '/usr/sbin/'],
        command => "/bin/mongo admin --host $openshift_origin::mongodb_replica_primary_ip_addr -u $openshift_origin::mongodb_admin_user -p $openshift_origin::mongodb_admin_password --quiet --eval \"printjson(rs.add(\'${ipaddress}:${port}\'))\"",
        unless  => "/bin/mongo admin --host $openshift_origin::mongodb_replica_primary_ip_addr -u $openshift_origin::mongodb_admin_user -p $openshift_origin::mongodb_admin_password --quiet --eval \"printjson(rs.status())\" | grep '\"name\" : \"${ipaddress}:${port}\"'",
        require => [Service['mongod'], Exec['keyfile-mongo-conf', 'replset-mongo-conf']],
      }
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
