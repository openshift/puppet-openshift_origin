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
define register_dns( $fqdn ) {
  if $::openshift_origin::register_host_with_named {
    if $fqdn != 'localhost' {
      ensure_resource( 'exec', "Register ${fqdn}", {
          command => template("openshift_origin/register_dns.erb"),
          provider => 'shell'
        }
      )
    }
  }
}

class openshift_origin::install_method {
  include openshift_origin::params

  case $::openshift_origin::install_method {
    'none' : {}
    'yum'  : { include openshift_origin::yum_install_method }
  }
}

class openshift_origin::role {
  include openshift_origin::params
  
  if ( $::openshift_origin::configure_ntp ) {
    ensure_resource('package', 'ntpdate', {
        ensure => 'present',
      }
    )

    ensure_resource('class', 'ntp', {
        servers    => ['time.apple.com iburst', 'pool.ntp.org iburst', 'clock.redhat.com iburst'],
        autoupdate => true,
      }
    )
  }
  
  ensure_resource( 'firewall', 'ssh', {
      service => 'ssh',
    }
  )

  ensure_resource( 'class', 'openshift_origin::install_method', {} )
}

class openshift_origin::role::broker inherits openshift_origin::role {
  register_dns{ 'register broker dns':
    fqdn => $::openshift_origin::broker_hostname 
  }
  ensure_resource( 'class', 'openshift_origin::client_tools', {} )
  ensure_resource( 'class', 'openshift_origin::broker', {} )
  ensure_resource( 'class', 'openshift_origin::console', {} )
}

class openshift_origin::role::named inherits openshift_origin::role {
  ensure_resource( 'class', 'openshift_origin::named', {} )
  register_dns{ 'register named dns':
    fqdn    => $::openshift_origin::named_hostname,
    require => Class['openshift_origin::named']
  }
}

class openshift_origin::role::node inherits openshift_origin::role {
  register_dns{ 'register node dns':
    fqdn => $::openshift_origin::node_hostname 
  }
  ensure_resource( 'class', 'openshift_origin::node', {} )
}

class openshift_origin::role::activemq inherits openshift_origin::role {
  register_dns{ 'register activemq dns':
    fqdn => $::openshift_origin::activemq_hostname 
  }
  ensure_resource( 'class', 'openshift_origin::activemq', {} )
}

class openshift_origin::role::datastore inherits openshift_origin::role {
  register_dns{ 'register datastore dns':
    fqdn => $::openshift_origin::datastore_hostname 
  }
  ensure_resource( 'class', 'openshift_origin::mongo', {} ) 
}
