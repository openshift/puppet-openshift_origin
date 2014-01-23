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
class openshift_origin::params {
  $os_init_provider     =  $::operatingsystem ? {
   # 'Fedora' => 'systemd',
    'CentOS' => 'redhat',
    default  => 'redhat',
  }
  
  $service   = $::operatingsystem ? {
    'Fedora' => '/sbin/service',
    default  => '/sbin/service',
  }

  $rpm       = $::operatingsystem ? {
    'Fedora' => '/bin/rpm',
    default  => '/bin/rpm',
  }

  $rm        = $::operatingsystem ? {
    'Fedora' => '/bin/rm',
    default  => '/bin/rm',
  }

  $touch     = $::operatingsystem ? {
    'Fedora' => '/bin/touch',
    default  => '/bin/touch',
  }

  $chown     = $::operatingsystem ? {
    'Fedora' => '/bin/chown',
    default  => '/bin/chown',
  }

  $httxt2dbm = $::operatingsystem ? {
    'Fedora' => '/bin/httxt2dbm',
    default  => '/usr/sbin/httxt2dbm',
  }

  $chmod     = $::operatingsystem ? {
    'Fedora' => '/bin/chmod',
    default  => '/bin/chmod',
  }

  $grep      = $::operatingsystem ? {
    'Fedora' => '/bin/grep',
    default  => '/bin/grep',
  }

  $cat       = $::operatingsystem ? {
    'Fedora' => '/bin/cat',
    default  => '/bin/cat',
  }

  $mv        = $::operatingsystem ? {
    'Fedora' => '/bin/mv',
    default  => '/bin/mv',
  }

  $echo      = $::operatingsystem ? {
    'Fedora' => '/bin/echo',
    default  => '/bin/echo',
  }
  
  $ruby_scl_prefix = $::operatingsystem ? {
    'Fedora' => '',
    default  => 'ruby193-',
  }
  
  $ruby_scl_path_prefix = $::operatingsystem ? {
    'Fedora' => '',
    default  => '/opt/rh/ruby193/root',
  }

  $sysctl      = $::operatingsystem ? {
    'Fedora' => '/sbin/sysctl',
    default  => '/sbin/sysctl',
  }
  
  $iptables    = $::operatingsystem ? {
    'Fedora' => '/sbin/iptables',
    default  => '/sbin/iptables',
  }
  
  $iptables_save_command = $operatingsystem ? {
    'Fedora' => "/sbin/service iptables save",
    default  => "/sbin/service iptables save",
  }
  
  $iptables_requires     = $operatingsystem ? {
    'Fedora' => ['iptables', 'iptables-services'],
    default  => ['iptables'],
  }
}
