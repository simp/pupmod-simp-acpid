# This class provides for the setup of the ACPI management subsystem.
#
# This will eventually grow to encompass all acpid capabilities.
#
# NOTE: This is NOT compatible with GFS2 and should not be included with it.
# They will deliberately step on one another.
#
# @param ensure
#   Management of the acpid package.
#
# @author https://github.com/simp/pupmod-simp-acpid/graphs/contributors
#
class acpid (
  String $ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {

  package { 'acpid': ensure => $ensure }

  if $facts['osfamily'] in ['RedHat'] {
    service { 'acpid':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      start      => '/sbin/service haldaemon stop; /sbin/service acpid start; /sbin/service haldaemon start',
      require    => Package['acpid']
    }
  }
  else {
    service { 'acpid':
      ensure     => 'running',
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require    => Package['acpid']
    }
  }
}
