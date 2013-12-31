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

class intel-ypclient
{
    $nisdomain = hiera( 'nisdomain' , 'basiscomm.ie' )
    $nishost1 = hiera( 'nishost1' , "nis-host1.${domain}" )
    $nishost2 = hiera( 'nishost2' , "nis-host2.${domain}" )

    $requireDefaultDomain = [ 'Slackware', 'Debian', 'Ubuntu', 'SLES' ]
    $requireYpConf = [ 'Centos', 'Fedora', 'RedHat', 'SLES', 'Ubuntu', 'Debian', 'Slackware', 'Gentoo', 'OpenSuSE' ]
    $requireNetwork = [ 'Centos', 'Fedora', 'RedHat' ] 

    if $osfamily == 'Debian' 
    {
        exec
        {
            "apt-get update":
                command  => '/usr/bin/apt-get update'
        }
    }

    package 
    { 
        'nis':
            ensure => latest,
            name => $osfamily ? 
            {
                'Debian' => "nis",
                default => "ypbind",
            }
    }

    # default domain
    if $operatingsystem in $requireDefaultDomain 
    {
        file
        {
            "/etc/defaultdomain":
                path => "/etc/defaultdomain",
                ensure => file,
                checksum => md5,
                mode => 664,
                content => template( "${module_name}/defaultdomain.erb" )
        }
    }
   

    # yp conf
    if $operatingsystem in $requireYpConf
    {
        file
        {
            "/etc/yp.conf":
                path => "/etc/yp.conf",
                ensure => file,
                checksum => md5,
                mode => 664,
                content => template( "${module_name}/yp.conf.erb" )
        }
    }


    # network
    if $operatingsystem in $requireNetwork
    {
        file
        {
            "/etc/sysconfig/network":
                path => "/etc/sysconfig/network",
                ensure => file,
                checksum => md5,
                mode => 664,
                content => template( "${module_name}/network.erb" )
        }
    }

}
