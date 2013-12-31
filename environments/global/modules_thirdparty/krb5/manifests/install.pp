# == Class: krb5::install
#
# Installs the required krb5 packages for operation as a client
#
class krb5::install {
  # packages required for client installation only.  if we ever add server
  # support, we should turn this into krb5::client::install and
  # krb5::server::install, with krb5::install containing the shared
  # dependencies.
  $packages = [
    'krb5-libs',
    'krb5-workstations'
  ]

  package { $packages: ensure => installed }
}
