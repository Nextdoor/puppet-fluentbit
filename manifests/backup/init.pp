# site/profile/logs.pp
# setup logs (fluentbit go binary)
class profile::logs (
  Optional[String]  $configfile = '/etc/td-agent-bit/td-agent-bit.conf',
  # template params output plugin
  String  $elastic_host           = undef,
  Integer $elastic_port           = undef,
  String  $elastic_index          = undef,
  Optional[String] $tls           = 'on',
  String  $basic_auth_user        = undef,
  String  $basic_auth_pass        = undef,
  # template params input plugin
  String  $td_agent_input_type    = 'docker',
  ) {

  class{"profile::logs::install": }
   -> class{"profile::logs::config": }
   -> class{"profile::logs::service": }

   contain profile::logs::install
   contain profile::logs::service

  # add apt key
  apt::key { 'fluentbit':
    source => 'https://packages.fluentbit.io/fluentbit.key',
    server => 'packags.fluentbit.io',
    id     => 'F209D8762A60CD49E680633B4FF8368B6EA0722A',
  }
  # configure repo
  -> apt::source { 'fluentbit':
    location => 'http://packages.fluentbit.io/ubuntu',
    release  => 'xenial',
    repos    => 'main',
  }
  # install package
  -> Package{ 'td-agent-bit': ensure => present, }
  # create service td-agent-bitbucket
  service { 'td-agent-bit':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  # configure td-agent
  file { $configfile:
    ensure  => file,
    mode    => '0644',
    content => template('profile/logs/td-agent-bit.conf.erb'),
    notify  => Service['td-agent-bit'],
  }
}
