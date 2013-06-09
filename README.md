# puppet-openshift_origin

# About

This module helps install [OpenShift Origin](https://openshift.redhat.com/community/open-source) Platform As A Service.
Through the declaration of the `openshift_origin` class, you can configure the OpenShift Origin Broker, Node and support
services including ActiveMQ, Qpid, MongoDB, named and OS settings including firewall, startup services, and ntp.

## Authors

* Jamey Owens
* Ben Klang
* Ben Langfeld
* Krishna Raman

# Requirements

* Puppet >= 2.7
* Facter >= 1.6.17
* Puppetlabs/stdlib module.  Can be obtained
  [here](http://forge.puppetlabs.com/puppetlabs/stdlib) or with the command
  `puppet module install puppetlabs/stdlib`
* Puppetlabs/ntp module.  Can be obtained
  [here](http://forge.puppetlabs.com/puppetlabs/ntp) or with the command
  `puppet module install puppetlabs/ntp`

# Installation

The module can be obtained from the
[github repository](https://github.com/kraman/puppet-openshift_origin).

1. Download the [Zip file from github](https://github.com/kraman/puppet-openshift_origin/archive/master.zip)
1. Upload the Zip file to your Puppet Master.
1. Unzip the file.  This will create a new directory called puppet-openshift_origin-{commit hash}
1. Rename this directory to just `openshift_origin` and place it in your
	   [modulepath](http://docs.puppetlabs.com/learning/modules1.html#modules).

# Configuration

There is one class (`openshift_origin`) that needs to be declared on all nodes managing
any component of OpenShift Origin. These nodes are configured using the parameters of
this class.

## Using Parameterized Classes

[Using Parameterized Classes](http://docs.puppetlabs.com/guides/parameterized_classes.html)

### Example: Single host (broker+console+node) which uses the Avahi MDNS and mongo Auth plugin:

    class { 'openshift_origin' :
      node_fqdn                  => "${hostname}.${domain}",
      cloud_domain               => 'openshift.local',
      dns_servers                => ['8.8.8.8'],
      os_unmanaged_users         => [],
      enable_network_services    => true,
      configure_firewall         => true,
      configure_ntp              => true,
      configure_activemq         => true,
      configure_mongodb          => true,
      configure_named            => false,
      configure_avahi            => true,
      configure_broker           => true,
      configure_node             => true,
      development_mode           => true,
      update_network_dns_servers => false,
      avahi_ipaddress            => '127.0.0.1',
      broker_dns_plugin          => 'avahi',
    }

### Example: Single host (broker+console+node) which uses the **Kerberos** Auth plugin and GSS-TSIG. 

    class { 'openshift_origin' :
      node_fqdn                  => "${hostname}.${domain}",
      cloud_domain               => 'openshift.local',
      dns_servers                => ['8.8.8.8'],
      os_unmanaged_users         => [],
      enable_network_services    => true,
      configure_firewall         => true,
      configure_ntp              => true,
      configure_activemq         => true,
      configure_mongodb          => true,
      configure_named            => false,
      configure_avahi            => true,
      configure_broker           => true,
      configure_node             => true,
      development_mode           => true,
      broker_auth_plugin         => 'kerberos',
      broker_dns_plugin          => 'nsupdate',
      broker_dns_gsstsig         => true,
      http_kerberos_keytab       => '/etc/http.keytab',
      dns_kerberos_keytab        => '/etc/dns.keytab'
      kerberos_realm             => 'EXAMPLE.COM',
      kerberos_service           => $node_fqdn,
    }

Please note:

* The Broker needs to be enrolled in the KDC as a host, `host/node_fqdn` as well as a service, `HTTP/node_fqdn`
* Keytab should be generated, is located on the Broker machine, and Apache should be able to access it (`chown apache <kerberos_keytab>`)
* Like the example config below:
  * set `broker_auth_plugin` to `'kerberos'`
  * set `http_kerberos_keytab` and `dns_kerberos_keytab` to the absolute file location of the keytab
  * set `kerberos_realm` to the kerberos realm that the Broker host is enrolled with
  * set `kerberos_service` to the FQDN of the enrolled kerberos service, e.g. `node_fqdn`
* After setup, to test:
  * authentication: `kinit <user>` then `curl -Ik --negotiate -u : <node_fqdn>`
  * GSS-TSIG (should return `nil`):
    `$ cd /var/www/openshift/broker`
    `$ bundle --local`
    `$ rails console`
    `$ d = OpenShift::DnsService.instance`
    `$ d.register_application "appname", "namespace", "node_fqdn"`
    `=> nil`
* For any errors, on the Broker, check `/var/log/openshift/broker/httpd/error_log`.


# Parameters

The following lists all the class parameters the `openshift_origin` class accepts.

### node_fqdn

The FQDN for this host

### create_origin_yum_repos

True if OpenShift Origin dependencies and OpenShift Origin nightly yum repositories should be created on this node.

### install_client_tools

True if OpenShift Client tools be installed on this node.

### enable_network_services

True if all support services be enabled. False if they are enabled by other classes in your catalog.

### configure_firewall

True if firewall should be configured for this node (Will blow away any existing configuration)

### configure_ntp

True if NTP should be configured on this node. False if ntp is configured by other classes in your catalog.

### configure_activemq

True if ActiveMQ should be installed and configured on this node (Used by m-collective)

### configure_qpid

True if Qpid message broker should be installed and configured on this node. (Optionally, used by m-collective. Replaced ActiveMQ)

### configure_mongodb

Set to true to setup mongo (This will start mongod). Set to 'delayed' to setup mongo upon next boot.

### configure_named

True if a Bind server should be configured and run on this node.

### configure_avahi

True if a Avahi server should be configured and run on this node. (This is an alternative to named. Only one should be enabled)

### configure_broker

True if an OpenShift Origin broker should be installed and configured on this node.

### configure_console

True if an OpenShift Origin console should be installed and configured on this node.

### configure_node

True if an OpenShift Origin node should be installed and configured on this node.

### set_sebooleans

Set to true to setup selinux booleans. Set to 'delayed' to setup selinux booleans upon next boot.

### install_repo

The YUM repository to use when installing OpenShift Origin packages. Specify `nightlies` to pull latest nightly
build or provide a URL for another YUM repository.

### named_ipaddress

IP Address of DNS Bind server (If running on a different node)

### avahi_ipaddress

IP Address of Avahi MDNS server (If running on a different node)

### mongodb_fqdn

FQDN of node running the MongoDB server (If running on a different node)

### mq_fqdn

FQDN of node running the message queue (ActiveMQ or Qpid) server (If running on a different node)

### broker_fqdn

FQDN of node running the OpenShift OpenShift broker server (If running on a different node)

### cloud_domain

DNS suffix for applications running on this PaaS. Eg. `cloud.example.com` applications will be
`<app>-<namespace>.cloud.example.com`
  
### dns_servers

Array of DNS servers to use when configuring named forwarding. Defaults to `['8.8.8.8', '8.8.4.4']`

### configure_fs_quotas

Enables quotas on the local node. Applicable only to OpenShift OpenShift Nodes.  If this setting is set to false, it is expected
that Quotas are configured elsewhere in the Puppet catalog

### console_session_secret

Secret used for signing Rails sessions.

### oo_device

Device on which gears are stored (`/var/lib/openshift`)

### oo_mount

Base mount point for `/var/lib/openshift directory`

### configure_cgroups

Enables cgoups on the local node. Applicable only to OpenShift OpenShift Nodes. If this setting is set to false, it is expected
that cgroups are configured elsewhere in the Puppet catalog

### configure_pam

Updates PAM settings on the local node to secure gear logins. Applicable only to OpenShift OpenShift Nodes. If this setting is
set to false, it is expected that cgroups are configured elsewhere in the Puppet catalog

### broker_auth_plugin

The authentication plugin to use with the OpenShift OpenShift Broker. Supported values are `'mongo'`,
`'basic-auth'`, and `'kerberos'`

### broker_auth_pub_key

Public key used to authenticate communication between node and broker. If left blank, this file is auto generated.

### broker_auth_priv_key

Private key used to authenticate communication between node and broker. If `broker_auth_pub_key` is left blank, this
file is auto generated.

### broker_auth_key_password

Password for `broker_auth_priv_key` private key

### broker_auth_salt

Salt used to generate authentication tokens for communication between node and broker.

### broker_session_secret

Secret used for signing Rails sessions.

### kerberos_keytab

The full/absolute path to the Kerberos keytab for the Broker service, e.g. `'/var/www/openshift/broker/http/conf.d/http.keytab'`.

### kerberos_realm

The hostname in all caps that the Broker host/service is enrolled with, e.g. `'EXAMPLE.COM'`

### kerberos_service

The fully-qualified domain name that the service is enrolled with in your Kerberos setup. Do not include `HTTP/`, just the fqdn, e.g. `'example.com'` or just `$node_fqdn`.

### broker_rsync_key

RSync Key used during move gear admin operations

### mq_provider

Message queue plugin to configure for mcollecitve. Defaults to `'activemq'` Acceptable values are
`'activemq'`, `'stomp'` and `'qpid'`

### mq_server_user

User to authenticate against message queue server

### mq_server_password

Password to authenticate against message queue server

### mongo_auth_user

User to authenticate against Mongo DB server

### mongo_db_name

name of the MongoDB database

### mongo_auth_password

Password to authenticate against Mongo DB server

### named_tsig_priv_key

TSIG signature to authenticate against the Bind DNS server.  

### os_unmanaged_users

List of users with UID which should not be managed by OpenShift. (By default OpenShift Origin PAM will reserve all 
UID's > 500 and prevent user logins)

### update_network_dns_servers

True if Bind DNS server specified in `named_ipaddress` should be added as first DNS server for application name.
resolution. (This should be false if using Avahi for MDNS updates)

### development_mode

Set to true to enable development mode and detailed logging

# Known Issues

## Facter

Facter broken on Fedora 17. http://projects.puppetlabs.com/issues/15001

    yumrepo { 'puppetlabs-products':
      name     => 'puppetlabs-products',
      descr    => 'Puppet Labs Products Fedora 17 - $basearch',
      baseurl  => 'http://yum.puppetlabs.com/fedora/f17/dependencies/\$basearch',
      gpgkey   => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
      enabled  => 1,
      gpgcheck => 1,
    }
    
    yumrepo { 'puppetlabs-deps':
      name     => 'puppetlabs-deps',
      descr    => 'Puppet Labs Dependencies Fedora 17 - $basearch',
      baseurl  => 'http://yum.puppetlabs.com/fedora/f17/products/\$basearch',
      gpgkey   => 'http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs',
      enabled  => 1,
      gpgcheck => 1,
    }
    
    package { 'facter':
      ensure  => latest,
      require => [Yumrepo['puppetlabs-products'],Yumrepo['puppetlabs-deps']],
    }
    
