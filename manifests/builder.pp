# == Class: wdbuilder::builder

class wdbuilder::builder {

package { [
'nodejs',
'npm',
'php5',
'php5-cli',
'git'
]:
    ensure => 'present',
}

exec { 'npm_registry_http':
    user => 'root',
    command => '/usr/bin/npm config set registry="http://registry.npmjs.org/"',
    require => Package['nodejs', 'npm'],
}

exec { 'grunt-cli_install':
    user => 'root',
    command => '/usr/bin/npm install -g grunt-cli',
    require => Exec['npm_registry_http'],
}

group { 'wdbuilder':
    ensure => present,
}

user { 'wdbuilder':
    ensure => 'present',
    home => '/data/wdbuilder',
    shell => '/bin/bash',
    managehome => true,
    system => true,
}

file { '/data/wdbuilder/.ssh':
    ensure => "directory",
    owner => 'wdbuilder',
    group => 'wdbuilder',
    require => User['wdbuilder'],
}

file { '/data/wdbuilder/.ssh/known_hosts':
    ensure => file,
    mode => '0755',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    source => 'puppet:///modules/wdbuilder/builder/ssh/known_hosts',
    require => File['/data/wdbuilder/.ssh'],
}

file { '/data/wdbuilder/.ssh/config':
    ensure => file,
    mode => '0755',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    source => 'puppet:///modules/wdbuilder/builder/ssh/config',
    require => File['/data/wdbuilder/.ssh'],
}

file { '/data/wdbuilder/wikidata/.git/hooks/commit-msg':
    ensure => file,
    mode => '0755',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    source => 'puppet:///modules/wdbuilder/builder/wikidata/git/hooks/commit-msg',
}

git::clone { 'wikidatabuilder':
    ensure => 'latest',
    directory => '/data/wdbuilder/buildscript',
    origin => 'https://github.com/wmde/WikidataBuilder.git',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    require => [ File['/data/wdbuilder/.ssh/config'], File['/data/wdbuilder/.ssh/known_hosts'] ],
}

git::clone { 'wikidata':
    ensure => 'latest',
    directory => '/data/wdbuilder/wikidata',
    origin => 'ssh://wikidatabuilder@gerrit.wikimedia.org:29418/mediawiki/extensions/Wikidata',
    # origin => 'git@github.com:addshore/WikidataBuild.git',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    require => File['/data/wdbuilder/.ssh/known_hosts'],
}

git::userconfig{ 'gitconf for wdbuilder user':
    homedir => '/data/wdbuilder',
    settings => {
    'user' => {
    'name' => 'WikidataBuilder',
    'email' => 'wikidata-services@wikimedia.de',
    },
    },
    require => User['wdbuilder'],
}

exec { 'npm_install':
    user => 'root',
    cwd => '/data/wdbuilder/buildscript',
    command => '/usr/bin/npm install',
    require => [
    Package['npm'],
    Git::Clone['wikidatabuilder']
    ],
}

file { '/data/wdbuilder/cron.sh':
    ensure => file,
    mode => '0755',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    source => 'puppet:///modules/wdbuilder/builder/cron.sh',
    require => [
    Exec['npm_install'],
    Git::Clone['wikidata']
    ],
}

cron { 'builder_cron':
    ensure => present,
    command => '/data/wdbuilder/cron.sh > /var/log/buildercron.log 2>&1',
    user => 'wdbuilder',
    hour => '10',
    minute => '0',
    require => [ File['/data/wdbuilder/cron.sh'], File['/data/wdbuilder/wikidata/.git/hooks/commit-msg'] ],
}

cron { 'puppet_module':
    ensure => present,
    command => 'cd /etc/puppet/modules/wdbuilder && git pull origin master > /var/log/wdbuilder_puppet_pull.log 2>&1',
    user => 'root',
    minute => '*/30',
}

}
