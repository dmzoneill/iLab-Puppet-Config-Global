#registry

####Table of Contents

1. [Overview - What is the Registry module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with Registry](#setup)
    * [What Registry affects](#what-registry-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with Registry](#beginning-with-registry)
    * [Puppet Enterprise Console](#puppet-enterprise-console)
4. [Usage - Configuration options and additional functionality](#usage)
    * [Defined Type: registry::value](#defined-type-registryvalue)
    * [Custom Type: registry_key](#custom-type-registrykey)
    * [Custom Type: registry_value](#custom-type-registryvalue)
    * [Defined Type: registry::service](#defined-type-registryservice)
    * [Purge Values](#purge-values)
    * [Puppet Enterprise: Compliance](#puppet-enterprise-compliance)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)


##Overview

The Registry module enables you to manage your Windows Registry from your *nix puppet master.

##Module Description

This module provides the types and providers necessary to create and manage Windows
Registry keys and values with Puppet. 

##Setup

###What Registry affects

* files, folders and services in Windows Registry    
* node manifests

###Setup requirements

For this module to run correctly, you must have [pluginsync enabled](http://docs.puppetlabs.com/guides/plugins_in_modules.html#enabling-pluginsync). 

This setting will ensure the types and providers are synchronized and available on the agent before the configuration run takes place. This is the default behavior of the puppet agent on Microsoft Windows platforms. 

###Beginning with Registry

To begin using Registry, you must download the module to your puppet master. This module is intended for installation on a *nix master for use with a Windows agent.

The bulk of Registry's capabilities comes from two resource types: `registry_key` and `registry_value`. Combined, these types allow you to specify the registry container and file(s) meant to be in it. 

The defined resource type `registry::value` allows you to manage registry values and the parent key in one fell swoop.

    registry::value { 'MyApp Setting1':
      key   => 'HKLM\Software\Vendor\PuppetLabs',
      value => setting1,
      data  => 'Hello World!'
    }
    
Within this defined type, you can specify multiple registry values for one registry key and manage both at once. 

If, on the other hand, you just want to manage a standalone key or value, you can declare each resource type individually in your site.pp manifest.

    registry_key { 'HKLM\System\CurrentControlSet\Services\Puppet':
      ensure => present,
    }

and/or

    registry_value { 'HKLM\System\CurrentControlSet\Services\Puppet\Description':
      ensure => present,
      type   => string,
      data   => "The Puppet Agent service periodically manages your configuration",
    }

The type or types you declare will be applied at the next catalog run, and each one will be managed individually.   

There are a few functions worth taking note of: 

* If Puppet creates a registry key, Windows will automatically create any necessary parent registry keys that do not already exist.
* Keys within HKEY_LOCAL_MACHINE (hklm) or HKEY_CLASSES_ROOT (hkcr) are supported.  Other predefined root keys (e.g. HKEY_USERS) are not currently supported.
* Puppet will not recursively delete registry keys.
* Any parent registry key managed by Puppet will be autorequired.

###Puppet Enterprise console

Follow the [instructions above](#beginning-with-registry), except add the defined resource type or custom types to a class that is or can be applied to your nodes. 

Once you have added the type(s) to a class, use the [Puppet Enterprise console](http://docs.puppetlabs.com/pe/2.5/console_classes_groups.html#classes) to assign the class to a Windows node or node group.

##Usage

###Defined Type: registry::value

The `registry::value` defined resource type allows you to use Puppet to manage the parent key for a particular value automatically. This defined type will automatically create and manage the parent key if it does not exist, in addition to managing the value.

    class myapp {
      registry::value { 'puppetmaster':
        key  => 'HKLM\Software\Vendor\PuppetLabs',
        data => 'puppet.puppetlabs.com',
      }
    }

In the above example, a value named 'puppetmaster' would be created inside the key `HKLM\Software\Vendor\PuppetLabs`.

The `registry::value` defined type only manages keys and values in the system-native architecture. In other words, 32-bit keys applied in a 64-bit OS won't be managed by this defined type; instead, you must use the custom resource types individually.

####Parameters in `registry::value`:

#####`data`

Lists the data inside the registry value. Data should be specified as a string value, unless you have set the `type` parameter to 'array'.

#####`key`

Specifies the path of the key the value(s) must be in.

#####`type`

Determines the type of the registry value(s).  Defaults to 'string'. Valid values are 'string', 'array', 'dword', 'qword', 'binary', or 'expand'.

#####`value`

Lists the name of the registry value(s) to manage.  This will be copied from the resource title if not specified.  

You can also use this parameter to set a specific registry value as the default value for the key. To do so you must name the value `'(default)'`.

    registry::value { 'Setting0':
      key???  => 'HKLM\System\CurrentControlSet\Services\Puppet',
     ???value => '(default)',
      data??? => "Hello World!",
    }

It is worth noting that you can still add additional values in a string (or array) after the default, though you may only have one default value per key. 

###Custom Type: registry_key

The `registry_key` custom type allows management of individual registry keys on Windows systems. 

    registry_key { 'HKLM\System\CurrentControlSet\Services\Puppet':
      ensure => present,
    }

This type may be used outside of the `registry::value` defined type for specific, customized requirements. 

####Parameters in `registry_key`

#####`ensure`

Determines whether or not the key must exist. If not included, the module will do nothing but make sure the other parameters are met if the key is found on a node; it will not force its existence or absence. Valid values are 'present' and 'absent'.

#####`path`

Specifies the path of registry key to manage. For example: `HKLM\Software`or `HKEY_LOCAL_MACHINE\Software\Vendor`. 

If Puppet is running on a 64-bit system, the 32-bit registry key can be explicitly managed using a prefix. For example: `32:HKLM\Software`.

#####`purge_values`

Whether to delete any registry value associated with this key that is not being managed by puppet. Valid values are 'true' and 'false'. 

[See below](#purge-values) for more information on how this parameter works.

###Custom Type: registry_value

The `registry_value` custom type allows management of individual registry values on Windows systems. 

    registry_value { 'HKLM\System\CurrentControlSet\Services\Puppet\Description':
      ensure => present,
      type   => string,
      data   => "The Puppet Agent service periodically manages your configuration",
    }

This type may be used outside of the `registry::value` defined type for specific, customized requirements. 

####Parameters in `registry_value`

#####`path`

Specifies the path of the registry value to manage. For example: `HKLM\Software\Value1` or `HKEY_LOCAL_MACHINE\Software\Vendor\Value2`. 

If Puppet is running on a 64-bit system, the 32-bit registry value can be explicitly managed using a prefix. For example: `32:HKLM\Software\Value3`

#####`ensure`

Determines whether or not the value must exist. If not included, the module will do nothing but make sure the other parameters are met if the value is found on a node; it will not force its existence or absence. Valid values are 'present' and 'absent'.

#####`type`

Determines the type of the registry value data. Valid values are 'string', 'array', 'dword', 'qword', 'binary', or 'expand'.

#####`data`

Lists the data inside the registry value. Data should be specified as a string value, unless you have set the `type` parameter to 'array'.

###Defined Type: registry::service

The `registry::service` defined resource type utilizes specific registry keys and values to manage service entries in the Microsoft service control framework. Specifically, `registry::service` manages the values in the key `HKLM\System\CurrentControlSet\Services\$name\`.

    registry::service { puppet:
      ensure       => present,
      display_name => "Puppet Agent",
      description  => "Periodically fetches and applies configurations from a Puppet master server.",
      command      => 'C:\PuppetLabs\Puppet\service\daemon.bat',
    }

This is an alternative approach to using INSTSRV.EXE [1](http://support.microsoft.com/kb/137890).

####Parameters in `registry::service`:

#####`ensure`

Determines whether or not the service is 'present' or 'absent'.

#####`display_name`

Sets the Display Name of the service.  Defaults to the title of the resource.

#####`description`

A description of the service.

#####`command`

Specifies the command to execute.

#####`start`

Specifies the starting mode of the service. Valid values are 'automatic', 'manual', and 'disabled'. 

The native service resource can also be used to manage this setting. You can read more about that [here](http://docs.puppetlabs.com/references/latest/type.html#service).

####Extended `registry::service` example

    class registry::service_example {
      # Define a new service named "Puppet Test" that is disabled.
      registry::service { 'PuppetExample1':
        display_name => "Puppet Example 1",
        description  => "This is a simple example managing the registry entries for a Windows Service",
        command      => 'C:\PuppetExample1.bat',
        start        => 'disabled',
      }
      registry::service { 'PuppetExample2':
        display_name => "Puppet Example 2",
        description  => "This is a simple example managing the registry entries for a Windows Service",
        command      => 'C:\PuppetExample2.bat',
        start        => 'disabled',
      }
    }

###Purge Values

The Registry module provides a means of ensuring that only Puppet-specified values are associated with a particular key. This is not default behavior, but a feature you must enable.

In order to make sure only the values specified via Puppet are associated
with a particular key, use the `purge_values => true` parameter of the
`registry_key` resource. Enabling this feature will delete any values not managed by Puppet. 

The `registry::purge_example` class provides a quick and easy way to see a demonstration of how this works. This example class has two modes of operation determined by the Facter fact `PURGE_EXAMPLE_MODE`: 'setup' or 'purge'.

To run the demonstration, make sure the `registry::purge_example` class is included in the node catalog, then set an environment variable in Power Shell. This will set up a registry key that contains six values. 

    PS C:\> $env:FACTER_PURGE_EXAMPLE_MODE = 'setup'
    PS C:\> puppet agent --test
    
    notice: /Stage[main]/Registry::Purge_example/Registry_key[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value3]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value2]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_key[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\SubKey]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value5]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value6]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\SubKey\Value1]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value1]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\SubKey\Value2]/ensure: created
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value4]/ensure: created
    notice: Finished catalog run in 0.14 seconds

Switching the mode to 'purge' will cause the class to only manage three of the
six `registry_value` resources.  The other three will be purged since the `registry_key` resource has `purge_values => true` specified in the manifest.
Notice how Value4, Value5 and Value6 are being removed.

    PS C:\> $env:FACTER_PURGE_EXAMPLE_MODE = 'purge'
    PS C:\> puppet agent --test
    
    notice: /Registry_value[hklm\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value4]/ensure: removed
    notice: /Registry_value[hklm\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value6]/ensure: removed
    notice: /Registry_value[hklm\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value5]/ensure: removed
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value3]/data: data changed 'key3' to 'should not be purged'
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value2]/data: data changed '2' to '0'
    notice: /Stage[main]/Registry::Purge_example/Registry_value[HKLM\Software\Vendor\Puppet Labs\Examples\KeyPurge\Value1]/data: data changed '1' to '0'
    notice: Finished catalog run in 0.16 seconds

###Puppet Enterprise: Compliance

The Registry module comes with a class that provides an example of how to use the audit metaparameter to inspect `registry_key` and `registry_value` resources with the Compliance feature of Puppet Enterprise.

To use this class, either 

    include registry::compliance_example

or, use the Puppet Enterprise console to assign the class to a Windows node or node group.

##Limitations

This module was developed for use on *nix puppet master with Windows puppet agents.

Please log tickets and issues at our [Module Issue Tracker](http://projects.puppetlabs.com/projects/modules).

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can???t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

Licensed under [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)