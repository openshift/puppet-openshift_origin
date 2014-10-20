# Copyright 2014 Red Hat, Inc., All rights reserved.
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
class openshift_origin::plugins::routing::nginx {
  include openshift_origin::firewall::apache
  
  anchor { 'openshift_origin::routing_begin': } ->
  Class['openshift_origin::firewall::apache'] ->
  anchor { 'openshift_origin::routing_end': }

  package {
    [
      'nginx14-nginx',
      'rubygem-openshift-origin-routing-daemon',
    ]:
    ensure  => present,
  }
  
  selboolean { 'httpd_can_network_connect':
    value      => 'on',
    persistent => true,
  }
  
  service { 'nginx14-nginx':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['nginx14-nginx'],
  }
  
  service { 'openshift-routing-daemon':
    ensure     => true,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['rubygem-openshift-origin-routing-daemon'],
  }
  
  file { 'routing-daemon':
    ensure  => present,
    path    => '/etc/openshift/routing-daemon.conf',
    content => template('openshift_origin/nginx/routing-daemon.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-routing-daemon'],
    notify  => Service['openshift-routing-daemon'],
  }

}
