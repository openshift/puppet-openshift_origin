# == Class: openshift_origin
#
# This is the main class to manage all the components of a OpenShift OpenShift
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
#
# [*create_origin_yum_repos*]
#
# True if OpenShift Origin dependencies and OpenShift Origin nightly yum repositories should be created on this node.
#
# [*install_client_tools*]
#
# True if OpenShift Client tools be installed on this node.
#
# [*enable_network_services*]
#
# True if all support services be enabled. False if they are enabled by other classes in your recipe.
#
# [*configure_firewall*]
#
# True if firewall should be configured for this node (Will blow away any existing configuration)
#
# [*configure_ntp*]
#
# True if NTP should be configured on this node. False if ntp is configured by other classes in your recipe.
#
# [*configure_activemq*]
#
# True if ActiveMQ should be installed and configured on this node (Used by m-collective)
#
# [*configure_qpid*]
#
# True if Qpid message broker should be installed and configured on this node. (Optionally, used by m-collective. Replaced ActiveMQ)
#
# [*configure_mongodb*]
#
# True if Mongo DB should be installed and configured on this node.
#
# [*configure_named*]
#
# True if a Bind server should be configured and run on this node.
#
# [*configure_broker*]
#
# True if an OpenShift Origin broker should be installed and configured on this node.
#
# [*configure_node*]
#
# True if an OpenShift Origin node should be installed and configured on this node.
#
# [*named_ipaddress*]
#
# IP Address of DNS Bind server (If running on a different node)
#
# [*mongodb_fqdn*]
#
# FQDN of node running the MongoDB server (If running on a different node)
#
# [*mq_fqdn*]
#
# FQDN of node running the message queue (ActiveMQ or Qpid) server (If running on a different node)
#
# [*broker_fqdn*]
#
# FQDN of node running the OpenShift OpenShift broker server (If running on a different node)
#
# [*cloud_domain*]
#
# DNS suffix for applications running on this PaaS.
# Eg. cloud.example.com
#   Applications will be <app>-<namespace>.cloud.example.com
#
# [*configure_fs_quotas*]
#
# Enables quotas on the local node. Applicable only to OpenShift OpenShift Nodes.
# If this setting is set to false, it is expected that Quotas are configured elsewhere in the
# Puppet recipe
#
# [*oo_device*]
#
# Device on which gears are stored (/var/lib/openshift)
#
# [*oo_mount*]
#
# Base mount point for /var/lib/openshift directory
#
# [*configure_cgroups*]
#
# Enables cgoups on the local node. Applicable only to OpenShift OpenShift Nodes.
# If this setting is set to false, it is expected that cgroups are configured elsewhere in the
# Puppet recipe
#
# [*configure_pam*]
#
# Updates PAM settings on the local node to secure gear logins. Applicable only to
# OpenShift OpenShift Nodes. If this setting is set to false, it is expected that
# cgroups are configured elsewhere in the Puppet recipe
#
# [*broker_auth_plugin*]
#
# The authentication plugin to use with the OpenShift OpenShift Broker. Supported
# values are 'mongo' and 'basic-auth'
#
# [*broker_auth_pub_key*]
#
# Public key used to authenticate communication between node and broker. If left blank,
# this file is auto generated.
#
# [*broker_auth_priv_key*]
#
# Private key used to authenticate communication between node and broker. If
# `broker_auth_pub_key` is left blank, this file is auto generated.
#
# [*broker_auth_key_password*]
#
# Password for `broker_auth_priv_key` private key
#
# [*broker_auth_salt*]
#
# Salt used to generate authentication tokens for communication between node and broker.
#
# [*broker_rsync_key*]
#
# TODO
#
# [*mq_provider*]
#
# Message queue plugin to configure for mcollecitve. Defaults to 'activemq'
# Acceptable values are 'activemq', 'stomp' and 'qpid'
#
# [*mq_server_user*]
#
# User to authenticate against message queue server
#
# [*mq_server_password*]
#
# Password to authenticate against message queue server
#
# [*mongo_auth_user*]
#
# User to authenticate against Mongo DB server
#
# [*mongo_auth_password*]
#
# Password to authenticate against Mongo DB server
#
# [*mongo_db_name*]
#
# name of the MongoDB database
#
# [*named_tsig_priv_key*]
#
# TSIG signature to authenticate against the Bind DNS server.
#
# [*update_network_dns_servers*]
#
# True if Bind DNS server specified in `named_ipaddress` should be added as first DNS server
# for application name resolution.

class openshift_origin(
  $node_fqdn                  = "${hostname}.${domain}",
  $create_origin_yum_repos    = true,
  $install_client_tools       = true,
  $enable_network_services    = true,
  $configure_firewall         = true,
  $configure_ntp              = true,
  $configure_activemq         = true,
  $configure_qpid             = false,
  $configure_mongodb          = true,
  $configure_named            = true,
  $configure_broker           = true,
  $configure_console          = true,
  $configure_node             = true,
  $install_repo               = "nightlies",

  $named_ipaddress            = $ipaddress,
  $mongodb_fqdn               = $node_fqdn,
  $mq_fqdn                    = $node_fqdn,
  $broker_fqdn                = $node_fqdn,
  $cloud_domain               = 'example.com',
  $dns_servers                = ['8.8.8.8', '8.8.4.4'],

  $configure_fs_quotas        = true,
  $oo_device                  = $gear_root_device,
  $oo_mount                   = $gear_root_mount,

  $configure_cgroups          = true,
  $configure_pam              = true,

  $broker_auth_plugin         = 'mongo',
  $broker_auth_pub_key        = '',
  $broker_auth_priv_key       = '',
  $broker_auth_key_password   = '',
  $broker_auth_salt           = 'ClWqe5zKtEW4CJEMyjzQ',
  $broker_rsync_key           = '',

  $mq_provider                = 'activemq',
  $mq_server_user             = 'mcollective',
  $mq_server_password         = 'marionette',
  $mongo_auth_user            = 'openshift',
  $mongo_db_name              = 'openshift_broker_dev',
  $mongo_auth_password        = 'mooo',
  $named_tsig_priv_key        = '',
  $os_unmanaged_users         = [],

  $update_network_dns_servers = true,
  $development_mode           = false,
)
{
  if $::facterversion == '1.6.16' {
    fail 'Factor version needs to be updated to atleast 1.6.17'
  }
  
  $service = $::operatingsystem  ? {
    "Fedora"  => '/usr/sbin/service',
    default   => '/sbin/service',
  }
  
  $rm = $::operatingsystem  ? {
    "Fedora"  => '/usr/bin/rm',
    default   => '/bin/rm',
  }
  
  $touch = $::operatingsystem  ? {
    "Fedora"  => '/usr/bin/touch',
    default   => '/bin/touch',
  }
  
  $chown = $::operatingsystem  ? {
    "Fedora"  => '/usr/bin/chown',
    default   => '/bin/chown',
  }
  
  $echo = $::operatingsystem  ? {
    "Fedora"  => '/usr/bin/echo',
    default   => '/bin/echo',
  }

  if $configure_ntp == true {
    include openshift_origin::ntpd
  }else{
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

  if $configure_mongodb == true {
    include openshift_origin::mongo
  }

  if $configure_named == true {
    include openshift_origin::named
  }

  if $create_origin_yum_repos == true {
    case $::operatingsystem {
      'Fedora' : {
        $mirror_base_url = "https://mirror.openshift.com/pub/openshift-origin/fedora-${::operatingsystemrelease}/${::architecture}/"
      }
      default  : {
        $mirror_base_url = "https://mirror.openshift.com/pub/openshift-origin/rhel-6/${::architecture}/"
      }
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

  ensure_resource( 'package', 'policycoreutils', {} )
  ensure_resource( 'package', 'mcollective', {} )
  ensure_resource( 'package', 'httpd', {} )
  ensure_resource( 'package', 'openssh-server', {} )

  if $enable_network_services == true {
    service { [httpd, network, sshd]:
      enable  => true,
      require => [Package['httpd'],Package['openssh-server']],
    }
  }else{
    if ! defined_with_params(Service['httpd'], {'enable' => true }) {
      warning 'Please ensure that httpd is enabled on node and broker machines'
    }
    if ! defined_with_params(Service['network'], {'enable' => true }) {
      warning 'Please ensure that network is enabled on node and broker nodes'
    }
    if ! defined_with_params(Service['sshd'], {'enable' => true }) {
      warning 'Please ensure that sshd is enabled on all nodes'
    }
  }

  if (($mq_provider == 'activemq' or $mq_provider == 'stomp') and $configure_activemq == true){
    $message_q_fqdn = $node_fqdn
  }
  if ($mq_provider == 'qpid' and $configure_qpid == true){
    $message_q_fqdn = $node_fqdn
  }
  if ($message_q_fqdn == '') {
    $message_q_fqdn = $mq_fqdn
  }

  if ($configure_broker == true or $configure_node == true) and $message_q_fqdn == ''{
    fail 'Please configure a message queue on this machine or provide the fqdn of the message queue server'
  }

  if( $configure_node == true ) {
    if ($configure_broker == false and $broker_fqdn == $node_fqdn) {
      fail 'Please provide the broker fqdn'
    }

    include openshift_origin::node
  }

  if( $configure_broker == true ) {
    include openshift_origin::broker
  }

  if( $configure_console == true ) {
    include openshift_origin::console
  }

  if $install_client_tools == true {
    #Install rhc tools. On RHEL/CentOS, this will install under ruby 1.8 environment
    ensure_resource( 'package', 'rhc', {
      ensure  => present,
      require => Yumrepo[openshift-origin],
    } )

    file { '/etc/openshift/express.conf':
      content => template('openshift_origin/express.conf.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['rhc']
    }
    
    if $::operatingsystem == "Redhat" {
      #Support gems and packages to allow rhc tools to run within SCL environment
      ensure_resource( 'package', 'ruby193-rubygem-net-ssh' , { ensure => present })
      ensure_resource( 'package', 'ruby193-rubygem-archive-tar-minitar' , { ensure => present })
      ensure_resource( 'package', 'ruby193-rubygem-commander' , { ensure => present })
          
      exec { 'gems to enable rhc in scl-193':
        command => '/usr/bin/scl enable ruby193 "gem install rspec --version 1.3.0 --no-rdoc --no-ri" ; \
          /usr/bin/scl enable ruby193 "gem install fakefs --no-rdoc --no-ri" ; \
          /usr/bin/scl enable ruby193 "gem install httpclient --version 2.3.2 --no-rdoc --no-ri" ;'
      }
    }
  }

  if $configure_firewall == true {
    $firewall_package = $use_firewalld ? {
      "true"  => "firewalld",
      default => "system-config-firewall-base",
    }
    
    ensure_resource( 'package', $firewall_package , {
      ensure => present,
      alias  => 'firewall-package',
    })
    
    exec { 'Open port for SSH':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-service=ssh",
        default => "/usr/sbin/lokkit --service=ssh",
      },
      require => Package['firewall-package']
    }
    exec { 'Open port for HTTP':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-service=http",
        default => "/usr/sbin/lokkit --service=http",
      },
      require => Package['firewall-package']
    }
    exec { 'Open port for HTTPS':
      command => $use_firewalld ? {
        "true"    => "/usr/bin/firewall-cmd --permanent --zone=public --add-service=https",
        default => "/usr/sbin/lokkit --service=https",
      },
      require => Package['firewall-package']
    }
  }

  if $update_network_dns_servers == true {
    augeas{ 'network setup' :
      context => '/files/etc/sysconfig/network-scripts/ifcfg-eth0',
      changes => [
        "set DNS1 ${ipaddress}",
        "set HWADDR ${macaddress_eth0}",
      ]
    }
  }
  
  if $::operatingsystem == "Redhat" {
    if ! defined(File['/etc/profile.d/scl193.sh']) {
      file { '/etc/profile.d/scl193.sh':
        ensure  => present,
        path    => '/etc/profile.d/scl193.sh',
        content => template('openshift_origin/rhel-scl-ruby193-env.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
      }
    }
  }
}
