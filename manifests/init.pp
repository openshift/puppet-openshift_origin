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
# == Class openshift_origin
#
# This is the main class to manage parameters for all OpenShift Origin
# installations.
#
# === Parameters
# [*roles*]
#   Choose from the following roles to be configured on this node.
#     * broker        - Installs the broker and console.
#     * node          - Installs the node and cartridges.
#     * msgserver     - Installs ActiveMQ message broker.
#     * datastore     - Installs MongoDB (not sharded/replicated)
#     * nameserver    - Installs a BIND dns server configured with a TSIG key for updates.
#     * load_balancer - Installs HAProxy and Keepalived for Broker API high-availability.
#   Default: ['broker','node','msgserver','datastore','nameserver']
#
#   Note: Multiple servers are required when using the load_balancer role.
# 
# [*install_method*]
#   Choose from the following ways to provide packages:
#     none - install sources are already set up when the script executes (default)
#     yum - set up yum repos manually
#       * repos_base
#       * os_repo
#       * os_updates_repo
#       * jboss_repo_base
#       * jenkins_repo_base
#       * optional_repo
#   Default: yum
#
# [*parallel_deployment*]
#   This flag is used to control some module behaviors when an outside utility
#   (like oo-install) is managing the deployment of OpenShift across multiple
#   hosts simultaneously. Some configuration tasks can't be performed during
#   a multi-host parallel installation and this boolean enables the user to
#   indicate whether or not thos tasks should be attempted.
#
#   Default: false
#
# [*repos_base*]
#   Base path to repository for OpenShift Origin
#   Nightlies:
#     Fedora: https://mirror.openshift.com/pub/origin-server/nightly/fedora-19
#     RHEL:   https://mirror.openshift.com/pub/origin-server/nightly/rhel-6
#   Release-2:
#     Fedora: https://mirror.openshift.com/pub/origin-server/release/2/fedora-19
#     RHEL:   https://mirror.openshift.com/pub/origin-server/release/2/rhel-6
#   Default: Fedora-19 Nightlies
#
# [*architecture*]
#   CPU Architecture to use for the definition OpenShift Origin yum repositories
#     Defaults to $::architecture
#     Fedora:
#       x86_64
#       armv7hl
#     RHEL:
#       x86_64
#
# [*override_install_repo*]
#   Repository path override. Uses dependencies from repos_base but uses
#   override_install_repo path for OpenShift RPMs. Used when doing local builds.
#   Default: none
#
# [*os_repo*]
#   The URL for a Fedora 19/RHEL 6 yum repository used with the "yum" install method.
#   Should end in x86_64/os/.
#   Default: no change
#
# [*os_updates*]
#   The URL for a Fedora 19/RHEL 6 yum updates repository used with the "yum" install method.
#   Should end in x86_64/.
#   Default: no change
#
# [*jboss_repo_base*]
#   The URL for a JBoss repositories used with the "yum" install method.
#   Does not install repository if not specified.
#
# [*jenkins_repo_base*]
#   The URL for a Jenkins repositories used with the "yum" install method.
#   Does not install repository if not specified.
#
# [*optional_repo*]
#   The URL for a EPEL or optional repositories used with the "yum" install method.
#   Does not install repository if not specified.
#
# [*domain*]
#   Default: example.com
#   The network domain under which apps and hosts will be placed.
#
# [*broker_hostname*]
# [*node_hostname*]
# [*nameserver_hostname*]
# [*msgserver_hostname*]
# [*datastore_hostname*]
#   Default: the root plus the domain, e.g. broker.example.com - except
#   nameserver=ns1.example.com
#
#   These supply the FQDN of the hosts containing these components. Used
#   for configuring the host's name at install, and also for configuring
#   the broker application to reach the services needed.
#
#   IMPORTANT NOTE: if installing a nameserver, the script will create
#   DNS entries for the hostnames of the other components being
#   installed on this host as well. If you are using a nameserver set
#   up separately, you are responsible for all necessary DNS entries.
#
# [*datastore1_ip_addr|datastore2_ip_addr|datastore3_ip_addr*]
#   Default: undef
#   IP addresses of the first 3 MongoDB servers in a replica set.
#   Add datastoreX_ip_addr parameters for larger clusters.
# 
# [*nameserver_ip_addr*]
#   Default: IP of a nameserver instance or current IP if installing on this
#   node. This is used by every node to configure its primary name server.
#   Default: the current IP (at install)
#
# [*bind_key*]
#   When the nameserver is remote, use this to specify the key for updates.
#   This is the "Key:" field from the .private key file generated by
#   dnssec-keygen. This field is required on all nodes.
#
# [*bind_key_algorithm*]
#   When using a BIND key, use this algorithm form the BIND key.
#   Default: 'HMAC-MD5'
#
# [*bind_krb_keytab*]
#   When the nameserver is remote, Kerberos keytab together with principal
#   can be used instead of the dnssec key for updates.
#
# [*bind_krb_principal*]
#   When the nameserver is remote, this Kerberos principal together with
#   Kerberos keytab can be used instead of the dnssec key for updates.
#
# [*aws_access_key_id*]
#    This and the next value are Amazon AWS security credentials.
#    The aws_access_key_id is a string which identifies an access credential.
#
#    http://docs.aws.amazon.com/AWSSecurityCredentials/1.0/AboutAWSCredentials.html#AccessCredentials.
#
# [*aws_secret_key*]
#    This is the secret portion of AWS Access Credentials indicated by the
#    aws_access_key_id
#
# [*aws_zone_id*]
#   This is the ID string for an AWS Hosted zone which will contain the
#   OpenShift application records.
#
#   http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/CreatingHostedZone.html
#
# [*conf_nameserver_upstream_dns*]
#   List of upstream DNS servers to use when installing nameserver on this node.
#   These DNS servers are also appended to the resolv.conf for all configured hosts
#   Default: ['8.8.8.8']
#
# [*broker_ip_addr*]
#   Default: the current IP (at install)
#   This is used for the node to record its broker. Also is the default
#   for the nameserver IP if none is given.
#
# [*broker_cluster_members*]
#   Default: undef
#   An array of broker hostnames that will be load-balanced for high-availability.
#
# [*broker_cluster_ip_addresses*]
#   Default: undef
#   An array of Broker IP addresses within the load-balanced cluster.
#
# [*broker_virtual_ip_address*]
#   Default: undef
#   The virtual IP address that will front-end the Broker cluster.
#
# [*broker_virtual_hostname*]
#   Default: "broker.${domain}"
#   The hostame that represents the Broker API cluster.  This name is associated
#   to broker_virtual_ip_address and added to Named for DNS resolution.
#
# [*load_balancer_master*]
#   Default: false
#   Sets the state of the load-balancer.  Valid options are true or false.
#   true sets load_balancer_master as the active listener for the Broker Cluster
#   Virtual IP address.
#
# [*load_balancer_auth_password*]
#   Default: 'changeme'
#   The password used to secure communication between the load-balancers
#   within a Broker cluster.
# 
# [*node_ip_addr*]
#   Default: the current IP (at install)
#   This is used for the node to give a public IP, if different from the
#   one on its NIC.
#
# [*node_profile*]
#   This is the specific node's gear profile
#
#   Default: small
#
# [*node_quota_files*]
#   The max number of files allowed in each gear.
#   
#   Default: 80000
#
# [*node_quota_blocks*]
#   The max storage capacity allowed in each gear (1 block = 1024 bytes)
#
#   Default: 1048576
#
# [*node_max_active_gears*]
#   max_active_gears is used for limiting/guiding gear placement.
#   For no over-commit, should be (Total System Memory - 1G) / memory_limit_in_bytes
#   
#   Default: 100
#   
# [*node_no_overcommit_active*]
#   no_overcommit_active enforces max_active_gears in a more stringent manner than normal,
#   however it also adds overhead to gear creation, so should only be set to true
#   when needed, like in the case of enforcing single tenancy on a node.
#   
#   Default: false
# 
# [*node_resource_limits*]
#   Resource limit options per node, these values must be the same across
#   districts. eg. district-small should all be using the same values.
#
#   node_limits_nproc=250                       # max number of processes
#   node_tc_max_bandwidth=800                   # mbit/sec - Total bandwidth allowed for Libra
#   node_tc_user_share=2                        # mbit/sec - one user is allotted...
#   node_cpu_shares=128                         # cpu share percentage for each gear
#   node_cpu_cfs_quota_us=100000                # cpu 
#   node_memory_limit_in_bytes=536870912        # gear memory limit in bytes (512MB)
#   node_memsw_limit_in_bytes=641728512  # gear max memory limit including swap (512M + 100M swap)
#   node_memory_oom_control=1                   # kill processes when hitting out of memory
#   node_throttle_cpu_shares=128                # cpu share percentage each gear gets at throttle   
#   node_throttle_cpu_cfs_quota_us=30000        #
#   node_throttle_apply_period=120              # 
#   node_throttle_apply_percent=30              # 
#   node_throttle_restore_percent=70            #
#   node_boosted_cpu_shares=256                 # cpu share percentage each gear gets while boosted
#   node_boosted_cpu_cfs_quota_us=200000        #
#
# [*configure_ntp*]
#   Default: true
#   Enabling this option configuresNTP.  It is important that the time
#   be synchronized across hosts because MCollective messages have a TTL
#   of 60 seconds and may be dropped if the clocks are too far out of
#   synch.  However, NTP is not necessary if the clock will be kept in
#   synch by some other means.
#
# [*ntp_servers*]
#   Default: ['time.apple.com iburst', 'pool.ntp.org iburst', 'clock.redhat.com iburst']
#   Specifies one or more servers for NTP clock syncronization.
#   Note: Use iburst after every ntp server definition to speed up
#         the initial synchronization.
#
# Passwords used to secure various services. You are advised to specify
# only alphanumeric values in this script as others may cause syntax
# errors depending on context. If non-alphanumeric values are required,
# update them separately after installation.
# 
# [*msgserver_cluster*]
#   Default: false
#   Set to true to cluster ActiveMQ for high-availability and scalability
#   of OpenShift message queues.
#
# [*msgserver_cluster_members*]
#   Default: undef
#   An array of ActiveMQ server hostnames.  Required when parameter
#   msgserver_cluster is set to true.
#
# [*mcollective_cluster_members*]
#   Default: $msgserver_cluster_members
#   An array of ActiveMQ server hostnames.  Required when parameter
#   msgserver_cluster is set to true.
#
# [*msgserver_password*]
#   Default 'changeme'
#   Password used by ActiveMQ's amquser.  The amquser is used to authenticate
#   ActiveMQ inter-cluster communication.  Only used when msgserver_cluster
#   is true.
#
# [*msgserver_admin_password*]
#   Default: scrambled
#   This is the admin password for the ActiveMQ admin console, which is
#   not needed by OpenShift but might be useful in troubleshooting.
#
# [*mcollective_user*]
# [*mcollective_password*]
#   Default: mcollective/marionette
#   This is the user and password shared between broker and node for
#   communicating over the mcollective topic channels in ActiveMQ. Must
#   be the same on all broker and node hosts.
#
# [*mongodb_admin_user*]
# [*mongodb_admin_password*]
#   Default: admin/mongopass
#   These are the username and password of the administrative user that
#   will be created in the MongoDB datastore. These credentials are not
#   used by in this script or by OpenShift, but an administrative user
#   must be added to MongoDB in order for it to enforce authentication.
#   Note: The administrative user will not be created if
#   CONF_NO_DATASTORE_AUTH_FOR_LOCALHOST is enabled.
#
# [*mongodb_broker_user*]
# [*mongodb_broker_password*]
#   Default: openshift/mongopass
#   These are the username and password of the normal user that will be
#   created for the broker to connect to the MongoDB datastore. The
#   broker application's MongoDB plugin is also configured with these
#   values.
#
# [*mongodb_name*]
#   Default: openshift_broker
#   This is the name of the database in MongoDB in which the broker will
#   store data.
# 
# [*mongodb_port*]
#   Default: '27017'
#   The TCP port used for MongoDB to listen on.
#
# [*mongodb_replicasets*]
#   Default: false
#   Enable/disable MongoDB replica sets for database high-availability.
#
# [*mongodb_replica_name*]
#   Default: 'openshift'
#   The MongoDB replica set name when $mongodb_replicasets is true.
#
# [*mongodb_replica_primary*]
#   Default: undef
#   Set the host as the primary with true or secondary with false.
#
# [*mongodb_replica_primary_ip_addr*]
#   Default: undef
#   The IP address of the Primary host within the MongoDB replica set.
#
# [*mongodb_replicasets_members*]
#   Default: undef
#   An array of [host:port] of replica set hosts. Example:
#   ['10.10.10.10:27017', '10.10.10.11:27017', '10.10.10.12:27017']
#
# [*mongodb_keyfile*]
#   Default: '/etc/mongodb.keyfile'
#   The file containing the $mongodb_key used to authenticate MongoDB
#   replica set members.
#
# [*mongodb_key*]
#   Default: 'changeme'
#   The key used by members of a MongoDB replica set to authenticate
#   one another.
#
# [*openshift_user1*]
# [*openshift_password1*]
#   Default: demo/changeme
#   This user and password are entered in the /etc/openshift/htpasswd
#   file as a demo/test user. You will likely want to remove it after
#   installation (or just use a different auth method).
#
# [*conf_broker_auth_salt*]
# [*conf_broker_auth_public_key*]
# [*conf_broker_auth_private_key*]
# [*conf_broker_auth_key_password*]
#   Salt, public and private keys used when generating secure authentication
#   tokens for Application to Broker communication. Requests like scale up/down
#   and jenkins builds use these authentication tokens. This value must be the
#   same on all broker nodes.
#   Default:  Self signed keys are generated. Will not work with multi-broker
#             setup.
#
# [*conf_broker_multi_haproxy_per_node*]
#   Default: false
#   This setting is applied on a per-scalable-application basis. When set to true,
#   OpenShift will allow multiple instances of the HAProxy gear for a given
#   scalable app to be established on the same node. Otherwise, on a
#   per-scalable-application basis, a maximum of one HAProxy gear can be created
#   for every node in the deployment (this is the default behavior, which protects
#   scalable apps from single points of failure at the Node level).
#
# [*conf_console_product_logo*]
#   Relative path to product logo URL
#   Default: '/assets/logo-origin.svg'
#
# [*conf_console_product_title*]
#   OpenShift Instance Name
#   Default: 'OpenShift Origin'
#
# [*conf_broker_session_secret*]
# [*conf_console_session_secret*]
#   Session secrets used to encode cookies used by console and broker. This
#   value must be the same on all broker nodes.
#
# [*conf_valid_gear_sizes*]
#   List of all gear sizes this will be used in this OpenShift installation.
#   Default: ['small']
#
# [*conf_default_gear_size*]
#   Default gear size if one is not specified
#   Default: 'small'
#
# [*conf_default_gear_capabilities*]
#   List of all gear sizes that newly created users will be able to create
#   Default: ['small']
#
# [*broker_dns_plugin*]
#   DNS plugin used by the broker to register application DNS entries.
#   Options:
#     * nsupdate - nsupdate based plugin. Supports TSIG and GSS-TSIG based
#                  authentication. Uses bind_key for TSIG and bind_krb_keytab,
#                  bind_krb_principal for GSS_TSIG auth.
#     * avahi    - sets up a MDNS based DNS resolution. Works only for
#                  all-in-one installations.
#     * route53  - use AWS Route53 for dynamic DNS service.
#                  Requires AWS key ID and secret and a delegated zone ID
#
#
# [*broker_auth_plugin*]
#   Authentication setup for users of the OpenShift service.
#   Options:
#     * mongo         - Stores username and password in mongo.
#     * kerberos      - Kerberos based authentication. Uses
#                       broker_krb_service_name, broker_krb_auth_realms,
#                       broker_krb_keytab values.
#     * htpasswd      - Stores username/password in a htaccess file.
#     * ldap          - LDAP based authentication. Uses broker_ldap_uri
#     * reverseproxy  - Relies on a reverse proxy to do authentication.
#                       For this to work properly, following headers must 
#                       be passed through to the backend:
#                       REMOTE_USER, Authorization, broker_key
#
#   Default: htpasswd
#
# [*broker_krb_service_name*]
#   The KrbServiceName value for mod_auth_kerb configuration
#
# [*broker_krb_auth_realms*]
# The KrbAuthRealms value for mod_auth_kerb configuration
#
# [*broker_krb_keytab*]
#   The Krb5KeyTab value of mod_auth_kerb is not configurable -- the keytab
#   is expected in /var/www/openshift/broker/httpd/conf.d/http.keytab
#
# [*broker_ldap_uri*]
#   URI to the LDAP server (e.g. ldap://ldap.example.com:389/ou=People,dc=my-domain,dc=com?uid?sub?(objectClass=*)).
#   Set <code>broker_auth_plugin</code> to <code>ldap</code> to enable
#   this feature.
#
# [*broker_ldap_bind_dn*]
# LDAP DN (Distinguished name) of user to bind to the directory with. (e.g. cn=administrator,cn=Users,dc=domain,dc=com)
# Default is anonymous bind.
#
# [*broker_ldap_bind_password*]
# Password of bind user set in broker_ldap_bind_dn.
# Default is anonymous bind with a blank password.
#
# [*broker_reverseproxy_ips*]
#  Array of IP Addresses of the proxy servers which are allowed to connect to the broker and console. Only these IPs will be allowed
#  to communicate directly to the API. Everything else must go through the reverseproxy.
#
#  Default: ['']
#
# [*node_shmmax*]
#   kernel.shmmax sysctl setting for /etc/sysctl.conf
#
#   This setting should work for most deployments but if this is desired to be
#   tuned higher, the general recommendations are as follows:
#
#    shmmax = shmall * PAGE_SIZE
#       - PAGE_SIZE = getconf PAGE_SIZE
#       - shmall = cat /proc/sys/kernel/shmall
#
#    shmmax is not recommended to be a value higher than 80% of total available
#    RAM on the system (expressed in BYTES).
#
#   Defaults:
#    64-bit:
#      kernel.shmmax = 68719476736
#    32-bit:
#      kernel.shmmax = 33554432
#
# [*node_shmall*]
#   kernel.shmall sysctl setting for /etc/sysctl.conf, this defaults to
#   2097152 BYTES
#
#   This parameter sets the total amount of shared memory pages that can be
#   used system wide. Hence, SHMALL should always be at least
#   ceil(shmmax/PAGE_SIZE).
#
#   Defaults:
#    64-bit:
#      kernel.shmall = 4294967296
#    32-bit:
#      kernel.shmall = 2097152
#
# [*node_container_plugin*]
#   Specify the container type to use on the node.
#   Options:
#     * selinux - This is the default OpenShift Origin container type.
#
# [*node_frontend_plugins*]
#   Specify one or more plugins to use register HTTP and web-socket connections
#   for applications.
#   Options:
#     * apache-mod-rewrite  - Mod-Rewrite based plugin for HTTP and HTTPS
#         requests. Well suited for installations with a lot of
#         creates/deletes/scale actions.
#     * apache-vhost        - VHost based plugin for HTTP and HTTPS. Suited for
#         installations with less app create/delete activity. Easier to
#         customize.  If apache-mod-rewrite is also selected, apache-vhost will be
#         ignored
#     * nodejs-websocket    - Web-socket proxy listening on ports 8000/8444
#     * haproxy-sni-proxy   - TLS proxy using SNI routing on ports 2303 through 2308
#         requires /usr/sbin/haproxy15 (haproxy-1.5-dev19 or later).
#   Default: ['apache-mod-rewrite','nodejs-websocket']
#
# [*node_unmanaged_users*]
#   List of user names who have UIDs in the range of OpenShift gears but must be
#   excluded from OpenShift gear setups.
#   Default: []
#
# [*conf_node_external_eth_dev*]
#   External facing network device. Used for routing and traffic control setup.
#   Default: eth0
#
# [*conf_node_supplementary_posix_groups*]
#   Name of supplementary UNIX group to add a gear to.
#
# [*conf_node_watchman_service*]
#   Enable/Disable the OpenShift Node watchman service
#   Default: true
#
#  [*conf_node_watchman_gearretries*]
#   Number of restarts to attempt before waiting RETRY_PERIOD
#   Default: 3
#
#  [*conf_node_watchman_retrydelay*]
#   Number of seconds to wait before accepting another gear restart
#   Default: 300
#
#  [*conf_node_watchman_retryperiod*]
#   Number of seconds to wait before resetting retries
#   Default: 28800
#
#  [*conf_node_watchman_statechangedelay*]
#   Number of seconds a gear must remain inconsistent with it's state before Watchman attempts to reset state
#   Default: 900
#
#  [*conf_node_watchman_statecheckperiod*]
#   Wait at least this number of seconds since last check before checking gear state on the Node. Use this to reduce Watchman's GearStatePlugin's impact on the system.
#   Default:  0
#
# [*development_mode*]
#   Set development mode and extra logging.
#   Default: false
#
# [*install_login_shell*]
#   Install a Getty shell which displays DNS, IP and login information. Used for
#   all-in-one VM installation.
#
# [*register_host_with_nameserver*]
#   Setup DNS entries for this host in a locally installed bind DNS instance.
#   Default: false
#
# [*dns_infrastructure_zone*]
#   The name of a zone to create which will contain OpenShift infrastructure
#
#   If this is unset then no infrastructure zone or other artifacts will be
#   created.
#
#   Default: ''
#
# [*dns_infrastructure_key*]
#   An dnssec symmetric key which will grant update access to the infrastucture
#   zone resource records.
#
#   This is ignored unless _dns_infrastructure_zone_ is set.
#
#   Default: ''
#
# [*dns_infrastructure_key_algorithm*]
#   The algorithm used for the dnssec symmetric key.
#
#   This is ignored unless _dns_infrastructure_zone_ is set.
#
#   Default: 'HMAC-MD5'
#
# [*dns_infrastructure_names*]
#   An array of hashes containing hostname and IP Address pairs to populate
#   the infrastructure zone.
#
#   This value is ignored unless _dns_infrastructure_zone_ is set.
#
#   Hostnames can be simple names or fully qualified domain name (FQDN).
#
#   Simple names will be placed in the _dns_infrastructure_zone_.
#   Matching FQDNs will be placed in the _dns_infrastructure_zone.
#   Hostnames anchored with a dot (.) will be added verbatim.
#
#   Default: []
#
#   Example:
#     $dns_infrastructure_names = [
#       {hostname => '10.0.0.1', ipaddr => 'broker1'},
#       {hostname => '10.0.0.2', ipaddr => 'data1'},
#       {hostname => '10.0.0.3', ipaddr => 'message1'},
#       {hostname => '10.0.0.11', ipaddr => 'node1'},
#       {hostname => '10.0.0.12', ipaddr => 'node2'},
#       {hostname => '10.0.0.13', ipaddr => 'node3'},
#     ]
#
# [*manage_firewall*]
#   Indicate whether or not this module will configure the firewall for you
#
# [*install_cartridges*]
#   List of cartridges to be installed on the node. Options:
#
#   * 10gen-mms-agent
#   * cron
#   * diy
#   * haproxy
#   * mongodb
#   * nodejs
#   * perl
#   * php
#   * phpmyadmin
#   * postgresql
#   * python
#   * ruby
#   * jenkins
#   * jenkins-client
#   * mariadb         (will install mysql on RHEL)
#   * jbossews
#   * jbossas
#   * jbosseap
#
#   Default: ['10gen-mms-agent','cron','diy','haproxy','mongodb',
#             'nodejs','perl','php','phpmyadmin','postgresql',
#             'python','ruby','jenkins','jenkins-client','mariadb']
#
# == Manual Tasks
#
# This script attempts to automate as many tasks as it reasonably can.
# Unfortunately, it is constrained to setting up only a single host at a
# time. In an assumed multi-host setup, you will need to do the
# following after the script has completed.
#
# 1. Set up DNS entries for hosts
#    If you installed BIND with the script, then any other components
#    installed with the script on the same host received DNS entries.
#    Other hosts must all be defined manually, including at least your
#    node hosts. oo-register-dns may prove useful for this.
#
# 2. Copy public rsync key to enable moving gears
#    The broker rsync public key needs to go on nodes, but there is no
#    good way to script that generically. Nodes should not have
#    password-less access to brokers to copy the .pub key, so this must
#    be performed manually on each node host:
#       # scp root@broker:/etc/openshift/rsync_id_rsa.pub /root/.ssh/
#    (above step will ask for the root password of the broker machine)
#       # cat /root/.ssh/rsync_id_rsa.pub >> /root/.ssh/authorized_keys
#       # rm /root/.ssh/rsync_id_rsa.pub
#    If you skip this, each gear move will require typing root passwords
#    for each of the node hosts involved.
#
# 3. Copy ssh host keys between the node hosts
#    All node hosts should identify as the same host, so that when gears
#    are moved between hosts, ssh and git don't give developers spurious
#    warnings about the host keys changing. So, copy /etc/ssh/ssh_* from
#    one node host to all the rest (or, if using the same image for all
#    hosts, just keep the keys from the image).
class openshift_origin (
  $roles                                = ['broker','node','msgserver','datastore','nameserver'],
  $install_method                       = 'yum',
  $parallel_deployment                  = false,
  $repos_base                           = $::operatingsystem ? {
                                            'Fedora' => 'https://mirror.openshift.com/pub/origin-server/nightly/fedora-19',
                                            default  => 'https://mirror.openshift.com/pub/origin-server/nightly/rhel-6',
                                          },
  $architecture                         = undef,
  $override_install_repo                = undef,
  $os_repo                              = undef,
  $os_updates_repo                      = undef,
  $jboss_repo_base                      = undef,
  $jenkins_repo_base                    = undef,
  $optional_repo                        = undef,
  $domain                               = 'example.com',
  $broker_hostname                      = "broker.${domain}",
  $node_hostname                        = "node.${domain}",
  $nameserver_hostname                  = "ns1.${domain}",
  $msgserver_hostname                   = "msgserver.${domain}",
  $datastore_hostname                   = "mongodb.${domain}",
  $datastore1_ip_addr                   = undef,
  $datastore2_ip_addr                   = undef,
  $datastore3_ip_addr                   = undef,
  $nameserver_ip_addr                   = $ipaddress,
  $bind_key                             = '',
  $bind_key_algorithm                   = 'HMAC-MD5',
  $bind_krb_keytab                      = '',
  $bind_krb_principal                   = '',
  $aws_access_key_id                    = '',
  $aws_secret_key                       = '',
  $aws_zone_id                          = '',
  $broker_ip_addr                       = $ipaddress,
  $broker_cluster_members               = undef,
  $broker_cluster_ip_addresses          = undef,
  $broker_virtual_ip_address            = undef,
  $broker_virtual_hostname              = "broker.${domain}",
  $load_balancer_master                 = false,
  $load_balancer_auth_password          = 'changeme',
  $node_ip_addr                         = $ipaddress,
  $node_profile                         = 'small',
  $node_quota_files                     = '8000',
  $node_quota_blocks                    = '1048576',
  $node_max_active_gears                = '100',
  $node_no_overcommit_active            = false,
  $node_limits_nproc                    = '250',
  $node_tc_max_bandwidth                = '800',
  $node_tc_user_share                   = '2',
  $node_cpu_shares                      = '128',
  $node_cpu_cfs_quota_us                = '100000',
  $node_memory_limit_in_bytes           = '536870912',
  $node_memsw_limit_in_bytes            = '641728512',
  $node_memory_oom_control              = '1',
  $node_throttle_cpu_shares             = '128',
  $node_throttle_cpu_cfs_quota_us       = '30000',
  $node_throttle_apply_period           = '120',
  $node_throttle_apply_percent          = '30',
  $node_throttle_restore_percent        = '70',
  $node_boosted_cpu_shares              = '256',
  $node_boosted_cpu_cfs_quota_us        = '200000',
  $configure_ntp                        = true,
  $ntp_servers                          = ['time.apple.com iburst', 'pool.ntp.org iburst', 'clock.redhat.com iburst'],
  $msgserver_cluster                    = false,
  $msgserver_cluster_members            = undef,
  $mcollective_cluster_members          = $msgserver_cluster_members,
  $msgserver_password                   = 'changeme',
  $msgserver_admin_password             = inline_template('<%= require "securerandom"; SecureRandom.base64 %>'),
  $mcollective_user                     = 'mcollective',
  $mcollective_password                 = 'marionette',
  $mongodb_admin_user                   = 'admin',
  $mongodb_admin_password               = 'mongopass',
  $mongodb_broker_user                  = 'openshift',
  $mongodb_broker_password              = 'mongopass',
  $mongodb_name                         = 'openshift_broker',
  $mongodb_port                         = '27017',
  $mongodb_replicasets                  = false,
  $mongodb_replica_name                 = 'openshift',
  $mongodb_replica_primary              = undef,
  $mongodb_replica_primary_ip_addr      = undef,
  $mongodb_replicasets_members          = undef,
  $mongodb_keyfile                      = '/etc/mongodb.keyfile',
  $mongodb_key                          = 'changeme',
  $openshift_user1                      = 'demo',
  $openshift_password1                  = 'changeme',
  $conf_broker_auth_salt                = inline_template('<%= require "securerandom"; SecureRandom.base64 %>'),
  $conf_broker_auth_key_password        = undef,
  $conf_broker_auth_public_key          = undef,
  $conf_broker_auth_private_key         = undef,
  $conf_broker_session_secret           = undef,
  $conf_broker_multi_haproxy_per_node   = false,
  $conf_console_product_logo            = '/assets/logo-origin.svg',
  $conf_console_product_title           = 'OpenShift Origin',
  $conf_console_session_secret          = undef,
  $conf_valid_gear_sizes                = ['small'],
  $conf_default_gear_capabilities       = ['small'],
  $conf_default_gear_size               = 'small',
  $broker_dns_plugin                    = 'nsupdate',
  $broker_auth_plugin                   = 'htpasswd',
  $broker_krb_service_name              = '',
  $broker_krb_auth_realms               = '',
  $broker_krb_keytab                    = '',
  $broker_ldap_uri                      = '',
  $broker_ldap_bind_dn                  = '',
  $broker_ldap_bind_password            = '',
  $broker_reverseproxy_ips              = [''],
  $node_shmmax                          = undef,
  $node_shmall                          = undef,
  $node_container_plugin                = 'selinux',
  $node_frontend_plugins                = ['apache-mod-rewrite','nodejs-websocket'],
  $node_unmanaged_users                 = [],
  $conf_node_external_eth_dev           = 'eth0',
  $conf_node_supplementary_posix_groups = '',
  $conf_node_watchman_service           = true,
  $conf_node_watchman_gearretries       = '3',
  $conf_node_watchman_retrydelay        = '300',
  $conf_node_watchman_retryperiod       = '28800',
  $conf_node_watchman_statechangedelay  = '900',
  $conf_node_watchman_statecheckperiod  = '0',
  $development_mode                     = false,
  $conf_nameserver_upstream_dns         = ['8.8.8.8'],
  $install_login_shell                  = false,
  $register_host_with_nameserver        = false,
  $dns_infrastructure_zone              = '',
  $dns_infrastructure_key               = '',
  $dns_infrastructure_key_algorithm     = 'HMAC-MD5',
  $dns_infrastructure_names             = [],
  $install_cartridges                   = ['10gen-mms-agent','cron','diy','haproxy','mongodb',
                                          'nodejs','perl','php','phpmyadmin','postgresql',
                                          'python','ruby','jenkins','jenkins-client','mariadb'],
  $update_conf_files                    = true,
  $manage_firewall                      = true,
){
  include openshift_origin::role

  if $msgserver_cluster and ! $msgserver_cluster_members and ! $mcollective_cluster_members {
    fail('msgserver_cluster_members and mcollective_cluster_members parameters are required when msgserver_cluster is set')
  }

  if member( $roles, 'nameserver' ) {
    class{ 'openshift_origin::role::nameserver':
      before => Class['openshift_origin::update_conf_files'],
    }
    if member( $roles, 'broker' ) {
      Class['openshift_origin::role::nameserver'] -> Class['openshift_origin::role::broker']
    }
    if member( $roles, 'node' ) {
      Class['openshift_origin::role::nameserver'] -> Class['openshift_origin::role::node']
    }
    if member( $roles, 'msgserver' ) {
      Class['openshift_origin::role::nameserver'] -> Class['openshift_origin::role::msgserver']
    }
    if member( $roles, 'datastore' ) {
      Class['openshift_origin::role::nameserver'] -> Class['openshift_origin::role::datastore']
    }
    if member( $roles, 'load_balancer' ) {
      Class['openshift_origin::role::nameserver'] -> Class['openshift_origin::role::load_balancer']
    }
  }

  # Anchors for containing the implementation class
  anchor { 'openshift_origin::begin': }

  Exec { path => '/usr/bin:/usr/sbin:/bin:/sbin' }

  if $::openshift_origin::manage_firewall {
    include openshift_origin::firewall
  }

  if member( $roles, 'broker' ) {
    class { 'openshift_origin::role::broker':
      require => Class['openshift_origin::update_conf_files']
    }
  }
  if member( $roles, 'node' ) {
    class { 'openshift_origin::role::node':
      require => Class['openshift_origin::update_conf_files']
    }
  }
  if member( $roles, 'msgserver' ) {
    class{ 'openshift_origin::role::msgserver':
      require => Class['openshift_origin::update_conf_files']
    }
  }
  if member( $roles, 'datastore' ) {
    class{ 'openshift_origin::role::datastore':
      require => Class['openshift_origin::update_conf_files']
    }
  }
  if member( $roles, 'load_balancer' ) {
    class{ 'openshift_origin::role::load_balancer':
      require => Class['openshift_origin::update_conf_files']
    }
  }

  class{ 'openshift_origin::update_conf_files': }

  anchor { 'openshift_origin::end': }
}
