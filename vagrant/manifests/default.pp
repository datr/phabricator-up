include augeas

$config = loadyaml('/vagrant/config.yml')

Exec {
  path => ['/usr/bin', '/bin'],
}

class { 'apt':
   always_apt_update => true,
   proxy_host => $config["proxyhost"],
   proxy_port => $config["proxyport"],
}

Package {
  require => Class['Apt'],
}

package { 'nginx' : }

service { "nginx" :
  ensure => running,
}

package { 'mysql-server' : }

package { 'php5-fpm' : }

service { "php5-fpm" :
  ensure => running,
}

package { 'php5-cli' : }
package { 'php5-mysql' : }
package { 'php5-curl' : }
package { 'php5-gd' : }

package { 'php-apc' : }

package { 'sendmail' : }

package { 'subversion' : }

file { '/etc/nginx/sites-available/phabricator' : 
  source => '/vagrant/files/etc/nginx/sites-available/phabricator',
  require => Package['nginx'],
}

file { '/etc/nginx/sites-enabled/phabricator' :
  ensure => 'link',
  target => '/etc/nginx/sites-available/phabricator',
  require => [Package['nginx'], File['/etc/nginx/sites-available/phabricator']],
  notify => Service['nginx'],
}

# Configure php

augeas { "php-server-timezone":
  incl => '/etc/php5/fpm/php.ini',
  lens => 'Php.lns',
  changes => ["set 'Date/date.timezone' 'UTC'"],
  notify => Service["php5-fpm"],
}

augeas { "php-cli-timezone":
  incl => '/etc/php5/cli/php.ini',
  lens => 'Php.lns',
  changes => ["set 'Date/date.timezone' 'UTC'"],
}

augeas { 'php-apc-stat' : 
  incl => '/etc/php5/fpm/conf.d/20-apc.ini',
  lens => 'Php.lns',
  changes => ["set '.anon/apc.stat' '0'"],
  notify => Service["php5-fpm"],
}

# Configure phabricator

file { '/opt/phabricator/conf/custom' :
  ensure => "directory",
}

file { '/opt/phabricator/conf/custom/dev.conf.php' :
  source => '/vagrant/files/opt/phabricator/conf/custom/dev.conf.php',
  require => File['/opt/phabricator/conf/custom'],
}

file { '/opt/phabricator/conf/local/ENVIRONMENT' :
  content => 'custom/dev',
}

exec { 'set up database' :
  command => '/opt/phabricator/bin/storage upgrade --force',
  require => [
    Package['php5-cli', 'mysql-server', 'php5-mysql'],
    File['/opt/phabricator/conf/custom/dev.conf.php', '/opt/phabricator/conf/local/ENVIRONMENT']
  ],
}

