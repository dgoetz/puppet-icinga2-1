# == Class: icinga2::feature::api
#
# This module configures the Icinga2 feature api.
#
# === Parameters
#
# [*ensure*]
#   Set to present enables the feature api, absent disabled it. Default is present.
#
# [*accept_config*]
#   Accept zone configuration. Default to false.
#
# [*accept_commands*]
#   Accept remote commands. Default to false.
#
# === Variables
#
# [*NodeName*]
#   Certname and Keyname based on constant NodeName.
#
# === Authors
#
# Icinga Development Team <info@icinga.org>
#
class icinga2::feature::api(
  $ensure          = present,
  $key             = true,
  $cert            = true,
  $cacert          = true,
  $accept_config   = false,
  $accept_commands = false,
) {

  include ::icinga2::params

  validate_re($ensure, [ '^present$', '^absent$' ],
    "${ensure} isn't supported. Valid values are 'present' and 'absent'.")
  validate_bool($key)
  validate_bool($cert)
  validate_bool($cacert)
  validate_bool($accept_config)
  validate_bool($accept_commands)

  $conf_dir  = $::icinga2::params::conf_dir
  $pki_dir   = $::icinga2::params::pki_dir
  $user      = $::icinga2::params::user
  $group     = $::icinga2::params::group
  $node_name = $::icinga2::_constants['NodeName']

  File {
    owner   => $user,
    group   => $group,
  }

  file { $pki_dir:
    ensure => directory,
  }

  # host private key
  if $key {
    file { "${pki_dir}/${node_name}.key":
      ensure => file,
      mode   => $::kernel ? {
        'windows' => undef,
        default   => '0600',
      },
      source => $::settings::hostprivkey,
      tag    => 'icinga2::config::file',
    }
  }

  # host certificate
  if $cert {
    file { "${pki_dir}/${node_name}.crt":
      ensure => file,
      source => $::settings::hostcert,
      tag    => 'icinga2::config::file',
    }
  }

  # ca certificat
  if $cacert {
    file { "${pki_dir}/ca.crt":
      ensure => file,
      source => $::settings::localcacert,
      tag    => 'icinga2::config::file',
    }
  }

  icinga2::feature { 'api':
    ensure => $ensure,
  }

}
