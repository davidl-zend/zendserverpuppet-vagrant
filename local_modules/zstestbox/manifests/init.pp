# == Class: zstestbox
#   Sanity checks and usage example for the Zend Server Puppet module
#
class zstestbox {
  class {'::zendserver': }

  #Get the demo sanity Zend Server app
  file {'/tmp/demo.zpk':
    ensure => present,
    source => "puppet:///modules/${module_name}/demo.zpk",
  }

  #Deploy the demo Zend Server sanity app
  zendserver::application { 'demo':
    ensure        => 'deployed',
    app_package   => '/tmp/demo.zpk',
    require       => [Zendserver::Sdk::Target['localadmin'],
                      File['/tmp/demo.zpk']],
  }

  #Add the localadmin sdk target - get parameters from facter
  zendserver::sdk::target { 'localadmin':
    zskey     => $::zend_api_key_name,
    zssecret  => $::zend_api_key_hash,
  }

  #Configure the local firewall to allow access to Zend Server
  class { 'firewall': }

  firewall { '100 allow http, https and Zend Server console access':
    port    => [80, 443, 10081, 10082],
    proto   => tcp,
    action  => accept,
  }

  #Setup local mysql server to test Zend Server cluster
  include ::mysql::server

  file {'/root/.zsapi.ini':
    ensure => link,
    target => '/.zsapi.ini',
  }
}
