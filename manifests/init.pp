# == Class: acpid
#
# This class provides for the setup of the ACPI management subsystem.
#
# This will eventually grow to encompass all acpid capabilities.
#
# NOTE: This is NOT compatible with GFS2 and should not be included with it.
# They will deliberately step on one another.
#
# == Parameters
#
# [*ensure*]
# Type: One of 'latest', or a version number.
# Default: latest
#   Management of the acpid package.
#
# == Authors
#
# Trevor Vaughan <tvaughan@onyxpoint.com>
#
class acpid (
  $ensure = 'latest'
) {
  package { 'acpid': ensure => $ensure }

  service { 'acpid':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    start      => '/sbin/service haldaemon stop; /sbin/service acpid start; /sbin/service haldaemon start',
    require    => Package['acpid']
  }
}
