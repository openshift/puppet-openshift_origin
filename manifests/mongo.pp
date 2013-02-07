class openshift_origin::mongo{
  ensure_resource( 'package', 'mongodb', { ensure  => present })
  ensure_resource( 'package', 'mongodb-server', { ensure  => present })

  file { 'Temporarily Disable mongo auth':
    ensure  => present,
    path    => '/etc/mongodb.conf',
    content => template('openshift_origin/mongodb/mongodb.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [Package['mongodb'],Package['mongodb-server']],
  }

  exec { 'start mongodb':
    command     => "/bin/rm -rf /var/log/mongodb/mongodb.log && \
     /usr/sbin/service mongod restart ; \
     /usr/bin/touch /var/log/mongodb/mongodb.log && \
     /usr/bin/chown mongodb:mongodb /var/log/mongodb/mongodb.log ; \
     /bin/fgrep '[initandlisten] waiting for connections' /var/log/mongodb/mongodb.log ; \
     while [ ! $? -eq 0 ] ; \
       do sleep 2 ; \
       /usr/bin/echo '.' ; \
       /bin/fgrep '[initandlisten] waiting for connections' /var/log/mongodb/mongodb.log ; \
     done",
    refreshonly => true,
    subscribe   => File['Temporarily Disable mongo auth'],
    require => [Package['mongodb'],Package['mongodb-server']],
  }

  exec { 'set mongo admin password' :
    command     =>
      "/usr/bin/mongo ${::ipaddress}/${::openshift_origin::mongo_db_name} --eval 'db.addUser(\"${::openshift_origin::mongo_auth_user}\", \"${::openshift_origin::mongo_auth_password}\")' && \
       /usr/bin/mongo ${::ipaddress}/admin --eval 'db.addUser(\"${::openshift_origin::mongo_auth_user}\", \"${::openshift_origin::mongo_auth_password}\")'",
    refreshonly => true,
    subscribe   => Exec['start mongodb'],
    notify      => Exec['re-enable mongo'],
    require => [Package['mongodb'],Package['mongodb-server']],
  }

  if $::openshift_origin::broker_auth_plugin == 'mongo' {
    exec { 'create mongo auth plugin admin user' :
      command     =>
        "/usr/bin/mongo ${::ipaddress}/openshift_broker_dev --eval 'db.auth_user.update({\"_id\":\"admin\"}, {\"_id\":\"admin\",\"user\":\"admin\",\"password_hash\":\"2a8462d93a13e51387a5e607cbd1139f\"}, true)'",
      refreshonly => true,
      subscribe   => Exec['start mongodb'],
      notify      => Exec['re-enable mongo'],
      require => [Package['mongodb'],Package['mongodb-server']],
    }
  }

  exec { 're-enable mongo':
    command     =>
      "/usr/bin/echo 'auth = true' >> /etc/mongodb.conf && \
      /usr/sbin/service mongod restart",
    refreshonly => true,
    require => [Package['mongodb'],Package['mongodb-server']],
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'mongod':
      require => [Package['mongodb'],Package['mongodb-server']],
      enable  => true,
      subscribe => Exec['re-enable mongo'],
    }
  }

  if $::openshift_origin::configure_firewall == true {
    exec { 'Open port for MongoDB':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-port=27017/tcp",
        default => "/usr/sbin/lokkit --port=27017:tcp",
      },
      require => [Package['mongodb'],Package['mongodb-server'],Package['firewall-package']],
    }
  }
}
