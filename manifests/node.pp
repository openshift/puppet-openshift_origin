# == Class: openshift_origin::node
#
# Manage an OpenShift Origin node.
#
# === Parameters
#
# None
#
# === Examples
#
#  include openshift_origin::node
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
class openshift_origin::node {
  include openshift_origin::params
  ensure_resource('package', 'rubygem-openshift-origin-node', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-node-util', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'pam_openshift', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-node-proxy', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-port-proxy', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'openshift-origin-msg-node-mcollective', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
  )

  ensure_resource('package', 'git', {
      ensure => present
    }
  )
  ensure_resource('package', 'make', {
      ensure => present
    }
  )
  ensure_resource('package', 'cronie', {
      ensure => present
    }
  )
  ensure_resource('package', 'oddjob', {
      ensure => present
    }
  )

  if $::openshift_origin::configure_firewall == true {
    $webproxy_http_port = $::use_firewalld ? {
      'true'  => '8000/tcp',
      default => '8000:tcp',
    }

    exec { 'Open HTTP port for Node-webproxy':
      command => "${openshift_origin::params::firewall_port_cmd}${webproxy_http_port}",
      require => Package['firewall-package'],
    }

    $webproxy_https_port = $::use_firewalld ? {
      'true'  => '8443/tcp',
      default => '8443:tcp',
    }

    exec { 'Open HTTPS port for Node-webproxy':
      command => "${openshift_origin::params::firewall_port_cmd}${webproxy_https_port}",
      require => Package['firewall-package'],
    }
  } else {
    warning 'Please ensure that ports 80, 443, 8000, 8443 are open for web requests'
  }

  file { 'node servername config':
    ensure  => present,
    path    => '/etc/httpd/conf.d/000001_openshift_origin_node_servername.conf',
    content => template('openshift_origin/node/openshift-origin-node_servername.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rubygem-openshift-origin-node'],
  }

  file { 'openshift node config':
    ensure  => present,
    path    => '/etc/openshift/node.conf',
    content => template('openshift_origin/node/node.conf.erb'),
    require => Package['rubygem-openshift-origin-node'],
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if !defined(File['mcollective client config']) {
    file { 'mcollective client config':
      ensure  => present,
      path    => '/etc/mcollective/client.cfg',
      content => template('openshift_origin/mcollective-client.cfg.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['mcollective'],
    }
  }

  if !defined(File['mcollective server config']) {
    file { 'mcollective server config':
      ensure  => present,
      path    => '/etc/mcollective/server.cfg',
      content => template('openshift_origin/mcollective-server.cfg.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['mcollective'],
    }
  }

  if($::operatingsystem == 'Redhat' or $::operatingsystem == 'CentOS') {
    if !defined(File['mcollective env']) {
      file { 'mcollective env':
        ensure  => present,
        path    => '/etc/sysconfig/mcollective',
        content => template('openshift_origin/rhel-scl-ruby193-env.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['mcollective'],
      }
    }
  }

  if $::openshift_origin::configure_fs_quotas == true {
    exec { 'Initialize quota DB':
      command => '/usr/sbin/oo-init-quota',
      creates => "${::gear_root_mount}/aquota.user",
      require => Package['openshift-origin-node-util'],
    }
  } else {
    warning 'Please ensure that quotas are enabled for /var/lib/openshift'
  }

  if $::openshift_origin::configure_fs_quotas == true {
    if $::operatingsystem == "Fedora" {
      if $::operatingsystemrelease == "18" {
        file { 'quota enable service':
          ensure  => present,
          path    => '/usr/lib/systemd/system/openshift-quotaon.service',
          content => template('openshift_origin/openshift-quotaon.service'),
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => [],
        }
        service { ['openshift-quotaon']:
          require => [
            File['quota enable service'],
          ],
          provider => 'systemd',
          enable => true,
        }
      }
    }
  }

  if $::openshift_origin::configure_cgroups == true {
    if $::openshift_origin::enable_network_services == true {
      service { [
        'cgconfig',
        'cgred',
        'openshift-cgroups',
        'openshift-port-proxy',
      ]:
        require => [
          Package['rubygem-openshift-origin-node'],
          Package['openshift-origin-node-util'],
          Package['openshift-origin-node-proxy'],
          Package['openshift-origin-port-proxy'],
        ],
        enable  => true,
      }
    } else {
      warning 'Please ensure that cgconfig, cgred, openshift-cgroups, openshift-port-proxy are running on all nodes'
    }
  } else {
    warning 'CGroups disabled'
  }

  if $::openshift_origin::configure_pam == true {
    $pam_sshd_template = $::operatingsystem ? {
      'Fedora' => template('openshift_origin/node/pam.sshd-fedora.erb'),
      default  => template('openshift_origin/node/pam.sshd-rhel.erb'),
    }

    file { 'openshift node pam sshd':
      ensure  => present,
      path    => '/etc/pam.d/sshd',
      content => $pam_sshd_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_runuser_template = $::operatingsystem ? {
      default => template('openshift_origin/node/pam.runuser-fedora.erb'),
    }

    file { 'openshift node pam runuser':
      ensure  => present,
      path    => '/etc/pam.d/runuser',
      content => $pam_runuser_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_runuser_l_template = $::operatingsystem ? {
      default => template('openshift_origin/node/pam.runuser-l-fedora.erb'),
    }

    file { 'openshift node pam runuser-l':
      ensure  => present,
      path    => '/etc/pam.d/runuser-l',
      content => $pam_runuser_l_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_su_template = $::operatingsystem ? {
      'Fedora' => template('openshift_origin/node/pam.su-fedora.erb'),
      default  => template('openshift_origin/node/pam.su-rhel.erb'),
    }

    file { 'openshift node pam su':
      ensure  => present,
      path    => '/etc/pam.d/su',
      content => $pam_su_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $pam_system_auth_ac_template = $::operatingsystem ? {
      'Fedora' => template('openshift_origin/node/pam.system-auth-ac-fedora.erb'),
      default  => template('openshift_origin/node/pam.system-auth-ac-rhel.erb'),
    }

    file { 'openshift node pam system-auth-ac':
      ensure  => present,
      path    => '/etc/pam.d/system-auth-ac',
      content => $pam_system_auth_ac_template,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    $os_all_unmanaged_users = [['root', 'adm', 'apache'], $::openshift_origin::os_unmanaged_users]

    file { 'openshift node pam-namespace sandbox.conf':
      ensure  => present,
      path    => '/etc/security/namespace.d/sandbox.conf',
      content => template('openshift_origin/node/namespace-d-sandbox.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    file { 'openshift node pam-namespace tmp.conf':
      ensure  => present,
      path    => '/etc/security/namespace.d/tmp.conf',
      content => template('openshift_origin/node/namespace-d-tmp.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }

    file { 'openshift node pam-namespace vartmp.conf':
      ensure  => present,
      path    => '/etc/security/namespace.d/vartmp.conf',
      content => template('openshift_origin/node/namespace-d-vartmp.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['pam_openshift'],
    }
  } else {
    warning 'Please configure pam on all nodes.'
  }

  file { 'sysctl config tweaks':
    ensure  => present,
    path    => '/etc/sysctl.conf',
    content => template('openshift_origin/node/sysctl.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  $printf = $::operatingsystem ? {
    'Fedora' => '/bin/printf "\nAcceptEnv GIT_SSH\n" >> "/etc/ssh/sshd_config"',
    default  => '/usr/bin/printf "\nAcceptEnv GIT_SSH\n" >> "/etc/ssh/sshd_config"'
  }

  exec { 'Update sshd configs':
    command => $printf,
    unless  => '/bin/grep -qFx \'AcceptEnv GIT_SSH\' \'/etc/ssh/sshd_config\''
  }

  if $::openshift_origin::enable_network_services == true {
    service { 'crond':
      enable  => true,
      require => Package['cronie']
    }

    service { 'oddjobd':
      enable  => true,
      require => Package['oddjob']
    }

    $openshift_init_provider = $::operatingsystem ? {
      'Fedora' => 'systemd',
      'CentOS' => 'redhat',
      default  => 'redhat',
    }

    service { ['openshift-gears', 'openshift-node-web-proxy']:
      require  => [
        Package['rubygem-openshift-origin-node'],
        Package['openshift-origin-node-util'],
        Package['openshift-origin-node-proxy'],
      ],
      provider => $openshift_init_provider,
      enable   => true,
    }

    service { 'mcollective':
      require => [Package['mcollective']],
      enable  => true,
    }
  } else {
    warning 'Please ensure that mcollective, cron, openshift-gears, openshift-node-web-proxy, and oddjobd are running on all nodes'
  }

  exec { 'Restoring SELinux contexts':
    command => '/sbin/restorecon -rv /var/lib/openshift \
          /var/lib/openshift/.httpd.d/',
    require => [Package['rubygem-openshift-origin-node']],
  }

  exec { 'jenkins repo key':
    command => "${::openshift_origin::rpm} --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
    creates => '/etc/yum.repos.d/jenkins.repo',
  }

  yumrepo { 'jenkins':
    name     => 'jenkins',
    baseurl  => 'http://pkg.jenkins-ci.org/redhat',
    enabled  => 1,
    gpgcheck => 1,
  }

  Exec['jenkins repo key'] -> Yumrepo['jenkins']

  if ($::openshift_origin::configure_broker == true and $::openshift_origin::configure_node == true) {
    file { 'broker and console route for node':
      ensure  => present,
      path    => '/tmp/nodes.broker_routes.txt',
      content => template('openshift_origin/node/node_routes.txt.erb'),
      owner   => 'root',
      group   => 'apache',
      mode    => '0640',
      require => Package['rubygem-openshift-origin-node'],
    }

    exec { 'regen node routes':
      command => "${::openshift_origin::cat} /etc/httpd/conf.d/openshift/nodes.txt /tmp/nodes.broker_routes.txt > /etc/httpd/conf.d/openshift/nodes.txt.new && \
                      ${::openshift_origin::mv} /etc/httpd/conf.d/openshift/nodes.txt.new /etc/httpd/conf.d/openshift/nodes.txt && \
                      ${::openshift_origin::httxt2dbm} -f DB -i /etc/httpd/conf.d/openshift/nodes.txt -o /etc/httpd/conf.d/openshift/nodes.db.new && \
                      ${::openshift_origin::chown} root:apache /etc/httpd/conf.d/openshift/nodes.txt /etc/httpd/conf.d/openshift/nodes.db.new && \
                      ${::openshift_origin::chmod} 750 /etc/httpd/conf.d/openshift/nodes.txt /etc/httpd/conf.d/openshift/nodes.db.new && \
                      ${::openshift_origin::mv} -f /etc/httpd/conf.d/openshift/nodes.db.new /etc/httpd/conf.d/openshift/nodes.db",
      unless  => "${::openshift_origin::grep} '__default__/broker' /etc/httpd/conf.d/openshift/nodes.txt 2>/dev/null",
      require => File['broker and console route for node'],
    }
  }

  package { [
    'openshift-origin-cartridge-abstract',
    'openshift-origin-cartridge-10gen-mms-agent-0.1',
    'openshift-origin-cartridge-cron-1.4',
    'openshift-origin-cartridge-diy-0.1',
    'openshift-origin-cartridge-haproxy-1.4',
    'openshift-origin-cartridge-mongodb-2.2',
    'openshift-origin-cartridge-mysql-5.1',
    'openshift-origin-cartridge-nodejs-0.6',
    'openshift-origin-cartridge-jenkins-1.4',
    'openshift-origin-cartridge-jenkins-client-1.4',
    'openshift-origin-cartridge-community-python-2.7',
    'openshift-origin-cartridge-community-python-3.3',
  ]:
    ensure  => present,
    require => [
      Yumrepo[openshift-origin],
      Yumrepo[openshift-origin-deps],
    ],
  }

  case $::operatingsystem {
    'Fedora' : {
      package { [
        'openshift-origin-cartridge-postgresql-9.2',
        'openshift-origin-cartridge-ruby-1.9',
        'openshift-origin-cartridge-php-5.4',
        'openshift-origin-cartridge-perl-5.16',
        'openshift-origin-cartridge-phpmyadmin-3.5',
      ]:
        ensure  => present,
        require => [
          Yumrepo[openshift-origin],
          Yumrepo[openshift-origin-deps],
        ],
      }
    }
    default  : {
      package { [
        'openshift-origin-cartridge-postgresql-8.4',
        'openshift-origin-cartridge-ruby-1.9-scl',
        'openshift-origin-cartridge-ruby-1.8',
        'openshift-origin-cartridge-php-5.3',
        'openshift-origin-cartridge-perl-5.10',
        'openshift-origin-cartridge-python-2.6',
        'openshift-origin-cartridge-phpmyadmin-3.4',
      ]:
        ensure  => present,
        require => [
          Yumrepo[openshift-origin],
          Yumrepo[openshift-origin-deps],
        ],
      }
    }
  }
}
