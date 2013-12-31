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

class intel-umap
{
    $fileserver = hiera( 'fileserver' , 'puppet.${domain}' )
    $unsupportedPKGManager = [ 'Slackware' ]
    
    if $operatingsystem in $unsupportedPKGManager
    {
        file
        {
            "/bin/umap":
                path => "/bin/umap",
                source => "puppet://${fileserver}/modules/${module_name}/umap",
                ensure => file,
                checksum => md5,
                mode => 755
        }
        
        file
        {
            "/bin/ucat":
                ensure => link,
                target => '/bin/umap'
        }

        notify 
        {
            "Unsupported package manager, you may need to install ksh manually":
        }
    }
    else
    {
        package 
        { 
            "ksh":   
                ensure => "installed" 
        }

        file
        {
            "/bin/umap":
                path => "/bin/umap",
                source => "puppet://${fileserver}/modules/${module_name}/umap",
                require => Package[ 'ksh' ],
                ensure => file,
                checksum => md5,
                mode => 755
        }
    
        file
        {
            "/bin/ucat":
                ensure => link,
                require => Package[ 'ksh' ],
                target => '/bin/umap'
        }
    }

}

