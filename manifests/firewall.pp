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
define firewall( $service=undef, $port=undef, $protocol=undef ) {
  ensure_resource('package', 'iptables', {})
  ensure_resource('package', 'firewalld', {
      ensure => 'absent',
    }
  )
  
  if $operatingsystem == 'Fedora' {
    ensure_resource('package', 'iptables-services', {})
  }
  
  ensure_resource( 'exec', 'Create IPTables rhc-app-comm chain for port proxying', {
      command  => template('openshift_origin/node/node_iptables.erb'),
      require  => Package[$::openshift_origin::params::iptables_requires],
      provider => 'shell'
    }
  )
  
  $lokkit = $::operatingsystem ? {
    'Fedora' => '/usr/sbin/lokkit',
    default  => '/sbin/lokkit',
  }
  
  case $::openshift_origin::firewall_provider {
    'none': {
    }
    'iptables': {
      ensure_resource( 'service', 'iptables', {
          require => Package[$::openshift_origin::params::iptables_requires],
          enable  => true,
        }
      )
    
      ensure_resource( 'exec', 'initial iptables setup', {
          command => "${::openshift_origin::params::iptables} -D INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT;
                      ${::openshift_origin::params::iptables} -I INPUT 1 -m state --state ESTABLISHED,RELATED -j ACCEPT;
                      ${::openshift_origin::params::iptables} -D INPUT -i lo -j ACCEPT;
                      ${::openshift_origin::params::iptables} -D INPUT -p icmp -j ACCEPT;
                      ${::openshift_origin::params::iptables} -I INPUT 2 -p icmp -j ACCEPT;                      
                      ${::openshift_origin::params::iptables} -I INPUT 3 -i lo -j ACCEPT;
                      ${::openshift_origin::params::iptables_save_command};",
          require => [Package[$::openshift_origin::params::iptables_requires]],
        }
      )
      
      ensure_resource( 'exec', 'final iptables setup', {
          command => "${::openshift_origin::params::iptables} -D INPUT -j REJECT --reject-with icmp-host-prohibited;
                      ${::openshift_origin::params::iptables} -A INPUT -j REJECT --reject-with icmp-host-prohibited;
                      ${::openshift_origin::params::iptables} -D FORWARD -j REJECT --reject-with icmp-host-prohibited;
                      ${::openshift_origin::params::iptables} -A FORWARD -j REJECT --reject-with icmp-host-prohibited;
                      ${::openshift_origin::params::iptables_save_command};",
          require => [Package[$::openshift_origin::params::iptables_requires]],
        }
      )
      
      if member( $::openshift_origin::roles, 'node' ) {
        Exec['initial iptables setup'] -> Exec['Create IPTables rhc-app-comm chain for port proxying'] -> Exec['final iptables setup']
      }
    
      if $service == undef {
        exec { "Open port ${port}:${protocol}":
          command => "${::openshift_origin::params::iptables} -D INPUT -m state --state NEW -m ${protocol} -p ${protocol} --dport ${port} -j ACCEPT;
                      ${::openshift_origin::params::iptables} -A INPUT -m state --state NEW -m ${protocol} -p ${protocol} --dport ${port} -j ACCEPT; 
                      ${::openshift_origin::params::iptables_save_command};",
          require => [Package[$::openshift_origin::params::iptables_requires],Exec['initial iptables setup'],],
          before  => Exec['final iptables setup'],
        }
      } else {
        $sport = $service ? {
          'http'  => '80',
          'https' => '443',
          'ssh'   => '22',
          'dns'   => '53',
        }
      
        $sprotocol = $service ? {
          'http'  => 'tcp',
          'https' => 'tcp',
          'ssh'   => 'tcp',
          'dns'   => 'tcp',
        }
      
        exec { "Open port ${sport}:${sprotocol} for service ${service}":
          command => "${::openshift_origin::params::iptables} -D INPUT -m state --state NEW -m ${sprotocol} -p ${sprotocol} --dport ${sport} -j ACCEPT;
                      ${::openshift_origin::params::iptables} -A INPUT -m state --state NEW -m ${sprotocol} -p ${sprotocol} --dport ${sport} -j ACCEPT;
                      ${::openshift_origin::params::iptables_save_command};",
          require => [Package[$::openshift_origin::params::iptables_requires],Exec['initial iptables setup']],
          before  => Exec['final iptables setup'],
        }
      }
    }
    'lokkit': {
      ensure_resource( 'service', 'iptables', {
          require => [Package['iptables-services']],
          enable  => true,
        }
      )
    
      ensure_resource('package', 'system-config-firewall-base', {})
      
      if $service == undef {
        exec { "Open port ${port}:${protocol}":
          command => "${lokkit} --port ${port}:${protocol}",
          require => Package['system-config-firewall-base'],
          before  => Exec['Create IPTables rhc-app-comm chain for port proxying']
        }
      } else {
        exec { "Open port for service ${service}":
          command => "${lokkit} --service ${service}",
          require => Package['system-config-firewall-base'],
          before  => Exec['Create IPTables rhc-app-comm chain for port proxying']
        }
      }
    }
  }
}
