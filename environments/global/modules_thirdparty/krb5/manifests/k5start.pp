# == Class: krb5::k5start
#
# Manages k5start, the daemon version of kinit
#
class krb5::k5start( $install = true ) {
  if $install {
    include krb5::k5start::install
    $k5start_package = Class['krb5::k5start::install']
  } else {
    if defined( Package[$krb5::k5start::install::packages] ) {
      $k5start_package = Package[$krb5::k5start::install::package]
    } else {
      $k5start_package = undef
    }
  }
}
