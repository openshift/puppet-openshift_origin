# == Class: openshift_origin
#
# This is the main class to manage all the components of a OpenShift Origin
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
# [*node_fqdn*]
#   The FQDN for this host
# [*create_origin_yum_repos*]
#   True if OpenShift Origin dependencies and OpenShift Origin nightly yum repositories should be created on this node.
# [*install_client_tools*]
#   True if OpenShift Client tools be installed on this node.
# [*enable_network_services*]
#   True if all support services be enabled. False if they are enabled by other classes in your catalog.
# [*configure_firewall*]
#   True if firewall should be configured for this node (Will blow away any existing configuration)
# [*configure_ntp*]
#   True if NTP should be configured on this node. False if ntp is configured by other classes in your catalog.
# [*configure_activemq*]
#   True if ActiveMQ should be installed and configured on this node (Used by m-collective)
# [*configure_qpid*]
#   True if Qpid message broker should be installed and configured on this node. (Optionally, used by m-collective. Replaced
#   ActiveMQ)
# [*configure_mongodb*]
#   Set to true to setup mongo (This will start mongod). Set to 'delayed' to setup mongo upon next boot.
# [*configure_named*]
#   True if a Bind server should be configured and run on this node.
# [*configure_avahi*]
#   True if a Avahi server should be configured and run on this node. (This is an alternative to named. Only one should be
#   enabled)
# [*configure_broker*]
#   True if an OpenShift Origin broker should be installed and configured on this node.
# [*configure_console*]
#   True if an OpenShift Origin console should be installed and configured on this node.
# [*configure_node*]
#   True if an OpenShift Origin node should be installed and configured on this node.
# [*use_v2_carts*]
#   True if an OpenShift Origin node should be configured to use v2 cartridges. (Alpha)
# [*set_sebooleans*]
#   Set to true to setup selinux booleans. Set to 'delayed' to setup selinux booleans upon next boot.
# [*install_repo*]
#   The YUM repository to use when installing OpenShift Origin packages. Specify <code>nightlies</code> to pull latest nightly
#   build or provide a URL for another YUM repository.
# [*named_ipaddress*]
#   IP Address of DNS Bind server (If running on a different node)
# [*avahi_ipaddress*]
#   IP Address of Avahi MDNS server (If running on a different node)
# [*mongodb_fqdn*]
#   FQDN of node running the MongoDB server (If running on a different node)
# [*mq_fqdn*]
#   FQDN of node running the message queue (ActiveMQ or Qpid) server (If running on a different node)
# [*broker_fqdn*]
#   FQDN of node running the OpenShift OpenShift broker server (If running on a different node)
# [*cloud_domain*]
#   DNS suffix for applications running on this PaaS. Eg. <code>cloud.example.com</code> applications will be
#   <code><app>-<namespace>.cloud.example.com</code>
# [*dns_servers*]
#   Array of DNS servers to use when configuring named forwarding. Defaults to <code>['8.8.8.8', '8.8.4.4']</code>
# [*configure_fs_quotas*]
#   Enables quotas on the local node. Applicable only to OpenShift OpenShift Nodes.  If this setting is set to false, it is expected
#   that Quotas are configured elsewhere in the Puppet catalog
# [*oo_device*]
#   Device on which gears are stored (<code>/var/lib/openshift</code>)
# [*oo_mount*]
#   Base mount point for <code>/var/lib/openshift directory</code>
# [*configure_cgroups*]
#   Enables cgoups on the local node. Applicable only to OpenShift OpenShift Nodes. If this setting is set to false, it is expected
#   that cgroups are configured elsewhere in the Puppet catalog
# [*configure_pam*]
#   Updates PAM settings on the local node to secure gear logins. Applicable only to OpenShift OpenShift Nodes. If this setting is
#   set to false, it is expected that cgroups are configured elsewhere in the Puppet catalog
# [*broker_auth_plugin*]
#   The authentication plugin to use with the OpenShift OpenShift Broker. Supported values are <code>'mongo'</code> and
#   <code>'basic-auth'</code>
# [*broker_auth_pub_key*]
#   Public key used to authenticate communication between node and broker. If left blank, this file is auto generated.
# [*broker_auth_priv_key*]
#   Private key used to authenticate communication between node and broker. If <code>broker_auth_pub_key</code> is left blank, this
#   file is auto generated.
# [*broker_auth_key_password*]
#   Password for `broker_auth_priv_key` private key
# [*broker_auth_salt*]
#   Salt used to generate authentication tokens for communication between node and broker.
# [*broker_rsync_key*]
#   RSync Key used during move gear admin operations
# [*mq_provider*]
#   Message queue plugin to configure for mcollecitve. Defaults to <code>'activemq'</code> Acceptable values are
#   <code>'activemq'</code>, <code>'stomp'</code> and <code>'qpid'</code>
# [*mq_server_user*]
#   User to authenticate against message queue server
# [*mq_server_password*]
#   Password to authenticate against message queue server
# [*mongo_auth_user*]
#   User to authenticate against Mongo DB server
# [*mongo_db_name*]
#   name of the MongoDB database
# [*mongo_auth_password*]
#   Password to authenticate against Mongo DB server
# [*named_tsig_priv_key*]
#   TSIG signature to authenticate against the Bind DNS server.  
# [*os_unmanaged_users*]
#   List of users with UID which should not be managed by OpenShift. (By default OpenShift Origin PAM will reserve all 
#   UID's > 500 and prevent user logins)
# [*update_network_dns_servers*]
#   True if Bind DNS server specified in <code>named_ipaddress</code> should be added as first DNS server for application name.
#   resolution. (This should be false if using Avahi for MDNS updates)
# [*development_mode*]
#   Set to true to enable development mode and detailed logging
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
class openshift_origin (
  $node_fqdn                  = $::fqdn,
  $create_origin_yum_repos    = true,
  $install_client_tools       = true,
  $enable_network_services    = true,
  $configure_firewall         = true,
  $configure_ntp              = true,
  $configure_activemq         = true,
  $configure_qpid             = false,
  $configure_mongodb          = true,
  $configure_named            = true,
  $configure_avahi            = false,  
  $configure_broker           = true,
  $configure_console          = true,
  $configure_node             = true,
  $use_v2_carts               = false,
  $set_sebooleans             = true,
  $install_login_shell        = false,
  $install_repo               = 'nightlies',
  $named_ipaddress            = $::ipaddress,
  $avahi_ipaddress            = $::ipaddress,  
  $mongodb_fqdn               = 'localhost',
  $mq_fqdn                    = $::fqdn,
  $broker_fqdn                = $::fqdn,
  $cloud_domain               = 'example.com',
  $dns_servers                = ['8.8.8.8', '8.8.4.4'],
  $configure_fs_quotas        = true,
  $oo_device                  = $::gear_root_device,
  $oo_mount                   = $::gear_root_mount,
  $configure_cgroups          = true,
  $configure_pam              = true,
  $broker_auth_plugin         = 'mongo',
  $broker_auth_pub_key        = '',
  $broker_auth_priv_key       = '',
  $broker_auth_key_password   = '',
  $broker_auth_salt           = 'ClWqe5zKtEW4CJEMyjzQ',
  $broker_rsync_key           = '',
  $broker_dns_plugin          = 'nsupdate',  
  $kerberos_keytab            = '/var/www/openshift/broker/httpd/conf.d/http.keytab',
  $kerberos_realm             = 'EXAMPLE.COM',
  $kerberos_service           = $::fqdn,
  $mq_provider                = 'activemq',
  $mq_server_user             = 'mcollective',
  $mq_server_password         = 'marionette',
  $mongo_auth_user            = 'openshift',
  $mongo_db_name              = 'openshift_broker_dev',
  $mongo_auth_password        = 'mooo',
  $named_tsig_priv_key        = '',
  $os_unmanaged_users         = [],
  $update_network_dns_servers = true,
  $development_mode           = false
) {
  include openshift_origin::params

  if $::facterversion <= '1.6.16' {
    fail 'Facter version needs to be updated to at least 1.6.17'
  }

  $service   = $::operatingsystem ? {
    'Fedora' => '/usr/sbin/service',
    default  => '/sbin/service',
  }

  $rpm       = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rpm',
    default  => '/bin/rpm',
  }

  $rm        = $::operatingsystem ? {
    'Fedora' => '/usr/bin/rm',
    default  => '/bin/rm',
  }

  $touch     = $::operatingsystem ? {
    'Fedora' => '/usr/bin/touch',
    default  => '/bin/touch',
  }

  $chown     = $::operatingsystem ? {
    'Fedora' => '/usr/bin/chown',
    default  => '/bin/chown',
  }

  $httxt2dbm = $::operatingsystem ? {
    'Fedora' => '/usr/bin/httxt2dbm',
    default  => '/usr/sbin/httxt2dbm',
  }

  $chmod     = $::operatingsystem ? {
    'Fedora' => '/usr/bin/chmod',
    default  => '/bin/chmod',
  }

  $grep      = $::operatingsystem ? {
    'Fedora' => '/usr/bin/grep',
    default  => '/bin/grep',
  }

  $cat       = $::operatingsystem ? {
    'Fedora' => '/usr/bin/cat',
    default  => '/bin/cat',
  }

  $mv        = $::operatingsystem ? {
    'Fedora' => '/usr/bin/mv',
    default  => '/bin/mv',
  }

  $echo      = $::operatingsystem ? {
    'Fedora' => '/usr/bin/echo',
    default  => '/bin/echo',
  }

  if $configure_ntp == true {
    include openshift_origin::ntpd
  } else {
    warning 'Please make sure ntp or some other time synchronization is enabled.'
    warning 'If date/time goes out of sync between broker and node machines then'
    warning 'mcollective commands may start failing.'
  }

  if $configure_activemq == true {
    include openshift_origin::activemq
  }

  if $configure_qpid == true {
    include openshift_origin::qpidd
  }

  if $configure_mongodb == true or $configure_mongodb == 'delayed' {
    include openshift_origin::mongo
  }

  if $configure_named == true {
    include openshift_origin::named
  }

  if $configure_avahi == true {
    include openshift_origin::avahi
  }

  if $create_origin_yum_repos == true {
    $mirror_base_url = $::operatingsystem ? {
      'Fedora' => "https://mirror.openshift.com/pub/openshift-origin/fedora-${::operatingsystemrelease}/${::architecture}/",
      'Centos' => "https://mirror.openshift.com/pub/openshift-origin/rhel-6/${::architecture}/",
      default  => "https://mirror.openshift.com/pub/openshift-origin/rhel-6/${::architecture}/",
    }

    yumrepo { 'openshift-origin-deps':
      name     => 'openshift-origin-deps',
      baseurl  => $mirror_base_url,
      enabled  => 1,
      gpgcheck => 0,
    }

    case $install_repo {
      'nightlies' : {
        case $::operatingsystem {
          'Fedora' : {
            $install_repo_path = "https://mirror.openshift.com/pub/openshift-origin/nightly/fedora-${::operatingsystemrelease}/latest/${::architecture}/"
          }
          default  : {
            $install_repo_path = "https://mirror.openshift.com/pub/openshift-origin/nightly/rhel-6/latest/${::architecture}/"
          }
        }
      }
      default     : {
        $install_repo_path = $install_repo
      }
    }

    yumrepo { 'openshift-origin-packages':
      name     => 'openshift-origin',
      baseurl  => $install_repo_path,
      enabled  => 1,
      gpgcheck => 0,
    }
  }

  ensure_resource('package', 'policycoreutils', {
  }
  )
  ensure_resource('package', 'mcollective', {
    require => Yumrepo['openshift-origin-deps'],
  }
  )
  ensure_resource('package', 'httpd', {
  }
  )
  ensure_resource('package', 'openssh-server', {
  }
  )

  ensure_resource('package', 'ruby-devel', {
      ensure  => present,
    }
  )


  if $enable_network_services == true {
    service { [httpd, network, sshd]:
      enable  => true,
      require => [Package['httpd'], Package['openssh-server']],
    }
  } else {
    if !defined_with_params(Service['httpd'], {
      'enable' => true
    }
    ) {
      warning 'Please ensure that httpd is enabled on node and broker machines'
    }

    if !defined_with_params(Service['network'], {
      'enable' => true
    }
    ) {
      warning 'Please ensure that network is enabled on node and broker nodes'
    }

    if !defined_with_params(Service['sshd'], {
      'enable' => true
    }
    ) {
      warning 'Please ensure that sshd is enabled on all nodes'
    }
  }

  if (($mq_provider == 'activemq' or $mq_provider == 'stomp') and $configure_activemq == true) {
    $message_q_fqdn = $node_fqdn
  }

  if ($mq_provider == 'qpid' and $configure_qpid == true) {
    $message_q_fqdn = $node_fqdn
  }

  if ($message_q_fqdn == '') {
    $message_q_fqdn = $mq_fqdn
  }

  if ($configure_broker == true or $configure_node == true) and $message_q_fqdn == '' {
    fail 'Please configure a message queue on this machine or provide the fqdn of the message queue server'
  }

  if ($configure_node == true) {
    if ($configure_broker == false and $broker_fqdn == $node_fqdn) {
      fail 'Please provide the broker fqdn'
    }

    include openshift_origin::node
  }

  if ($configure_broker == true) {
    include openshift_origin::broker
  }

  if ($configure_console == true) {
    include openshift_origin::console
  }
  
  if ($set_sebooleans == true or $set_sebooleans == 'delayed') {
    include openshift_origin::selinux
  }
  
  if ($install_login_shell == true) {
    include openshift_origin::custom_shell
  }

  if $install_client_tools == true {
    # Install rhc tools. On RHEL/CentOS, this will install under ruby 1.8 environment
    ensure_resource('package', 'rhc', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    }
    )

    file { '/etc/openshift/express.conf':
      content => template('openshift_origin/express.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['rhc'],
    }

    if $::operatingsystem == 'Redhat' {
      # Support gems and packages to allow rhc tools to run within SCL environment
      ensure_resource('package', 'ruby193-rubygem-net-ssh', {
        ensure => present,
      }
      )
      ensure_resource('package', 'ruby193-rubygem-archive-tar-minitar', {
        ensure => present,
      }
      )
      ensure_resource('package', 'ruby193-rubygem-commander', {
        ensure => present,
      }
      )

      exec { 'gems to enable rhc in scl-193':
        command => '/usr/bin/scl enable ruby193 "gem install rspec --version 1.3.0 --no-rdoc --no-ri" ; \
          /usr/bin/scl enable ruby193 "gem install fakefs --no-rdoc --no-ri" ; \
          /usr/bin/scl enable ruby193 "gem install httpclient --version 2.3.2 --no-rdoc --no-ri" ;'
      }
    }
  }

  if $configure_firewall == true {
    ensure_resource('package', $openshift_origin::params::firewall_package, {
      ensure => present,
      alias  => 'firewall-package',
    }
    )

    exec { 'Open port for SSH':
      command => "${openshift_origin::params::firewall_service_cmd}ssh",
      require => Package['firewall-package'],
    }

    exec { 'Open port for HTTP':
      command => "${openshift_origin::params::firewall_service_cmd}http",
      require => Package['firewall-package'],
    }

    exec { 'Open port for HTTPS':
      command => "${openshift_origin::params::firewall_service_cmd}https",
      require => Package['firewall-package'],
    }
  }

  if $update_network_dns_servers == true {
    augeas { 'network setup':
      context => '/files/etc/sysconfig/network-scripts/ifcfg-eth0',
      changes => ["set DNS1 ${named_ipaddress}", "set HWADDR ${::macaddress_eth0}"],
    }
  }

  if($::operatingsystem == 'Redhat' or $::operatingsystem == 'CentOS') {
    if !defined(File['/etc/profile.d/scl193.sh']) {
      file { '/etc/profile.d/scl193.sh':
        ensure  => present,
        path    => '/etc/profile.d/scl193.sh',
        content => template('openshift_origin/rhel-scl-ruby193-env.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }
    }
  }
}
