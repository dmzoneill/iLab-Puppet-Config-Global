# == Class: config
#
# Full description of class config here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { config:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

class intel-resolv
{
    $dnsdomain = hiera( 'dnsdomain' , "${domain}" )
    $dnssearch = hiera( 'dnssearch' , "${domain} intel.com " )
    $dnshost1 = hiera( 'dnshost1' , "10.248.2.1" )
    $dnshost2 = hiera( 'dnshost2' , "163.33.253.68" )
    $dnshost3 = hiera( 'dnshost3' , "10.184.9.1" )
    
    file
    {
        "/etc/resolv.conf":
            path => "/etc/resolv.conf",
            ensure => file,
            checksum => md5,
            mode => 664,
            content => template( "${module_name}/resolv.conf.erb" )
    }
}
