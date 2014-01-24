# == Class: wmde::wikidatabuilder

class wmde::wikidatabuilder {

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
    home => '/home/wdbuilder',
    shell => '/bin/bash',
    managehome => true,
}

git::clone { 'wikidatabuilder':
    ensure => 'latest',
    directory => '/home/wdbuilder/buildscript',
    origin => 'https://github.com/wmde/WikidataBuilder.git',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    require => User['wdbuilder'],
}

git::clone { 'wikidata':
    ensure => 'latest',
    directory => '/home/wdbuilder/wikidata',
    # TODO use a different repo once deploying!
    # origin => 'ssh://USER@gerrit.wikimedia.org:29418/mediawiki/extensions/Wikidata.git',
    origin => 'git@github.com:addshore/WikidataBuild.git',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    require => User['wdbuilder'],
}

git::userconfig{ 'gitconf for wdbuilder user':
    homedir => '/home/wdbuilder',
    settings => {
        'user' => {
            'name' => 'WikidataBuilder',
            'email' => 'wikidata@wikimedia.de',
        },
    },
    require => User['wdbuilder'],
}

exec { 'npm_install':
    user => 'root',
    cwd => '/home/wdbuilder/buildscript',
    command => '/usr/bin/npm install',
    require => [
        Package['npm'],
        Git::Clone['wikidatabuilder']
    ],
}

file { '/home/wdbuilder/wikidatabuilder_cron.sh':
    ensure => file,
    mode => '0755',
    owner => 'wdbuilder',
    group => 'wdbuilder',
    source => 'puppet:///modules/wmde/wikidatabuilder_cron.sh',
    require => [
        Exec['npm_install'],
        Git::Clone['wikidata']
    ],
}

# TODO uncomment when ready
# cron { 'builder_cron':
#     ensure => present,
#     # TODO commit the build to another repo
#     command => '/home/wdbuilder/wikidatabuilder_cron.sh > /var/log/buildercron.log 2>&1',
#     user => 'wdbuilder',
#     hour => '*/1',
#     minute => [ 0, 30 ],
#     require => [ File['/home/wdbuilder/wikidatabuilder_cron.sh'] ],
# }

}