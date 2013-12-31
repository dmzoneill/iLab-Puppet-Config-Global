define krb5::k5start::initscript (
  $owner = undef,
  $owner_uid = undef,
  $minutes = undef,
  $options = undef,
  $keytab = undef
) {
  include krb5::k5start

  $owner_r = $owner
  $owner_uid_r = $owner_uid
  $minutes_r = $minutes
  $options_r = $options
  $keytab_r = $keytab
  $name_r = $name

  file { "/etc/init.d/k5start-${name_r}":
    ensure  => present,
    mode    => '0550',
    owner   => root,
    group   => root,
    content => template('krb5/k5start.init.erb'),
  }
}
