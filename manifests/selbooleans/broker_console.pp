# Copyright 2014 Red Hat, Inc., All rights reserved.
#
# == Class openshift_origin::selbooleans::broker_console
# These SELinux booleans and restorecon commands must be set on any OpenShift Broker / console host.
#
class openshift_origin::selbooleans::broker_console {
  selboolean {
    [
      'httpd_execmem',
      'allow_ypbind',
      'httpd_verify_dns',
    ]:
    value      => 'on',
    persistent => true,
  }
  exec { 'Broker / Console restorecon commands':
    command => template('openshift_origin/selinux/broker_console_restorecons.erb'),
    require => Package['openshift-origin-broker','openshift-origin-console'],
    notify  => Service['openshift-broker'],
    timeout => 1800,
  }
}
