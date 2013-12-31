# == Class: krb5
#
# Manages kerberos 5 client configuration
#
class krb5 ( $install = true ) {
  if $install { include krb5::install }
}
