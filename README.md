Wikidata Builder
=========

This repo contains a puppet module to automate the building of the Wikidata product!

This module installs all dependencies, clones a few repos and sets up a cron!

Installation
-----------

1. Create an instance on labs, call it something like "wikidata-builderN".
2. Run Puppet
> puppetd -tv
6. On wikitech > Manage Instances > Instance > Configure > enable "role::puppet::self".
4. Run Puppet
> puppetd -tv
5. Clone this repo as a puppet module
> git clone https://github.com/wmde/puppet-builder.git /etc/puppet/modules/wdbuilder
6. On wikitech > Manage Puppet Groups > Project > Add class > "wdbuilder::builder".
7. Run Puppet
> puppetd -tv
8. Make a public / private key for the wdbuidler user
> ssh-keygen -t rsa
9. Copy the public key to gerrit from /home/wdbuilder/.ssh for the WikidataBuilder user
10. Run the bash script and see if it all works!
> /home/wdbuilder/cron.sh

Troubleshooting
-----------

* The instance needs to be aware of the RSA fingerprint for gerrit and github to be able to git clone correctly.
Currently this is not part of puppet and thus if this is a problem you will need to add the fingerprints!
The easiest way to do this is just to clone a repo from gerrit / github and when it asks "Are you sure you want to continue connecting (yes/no)" pick Yes!

* Sometimes the composer install will fail with a timeout exception. This is likely due to the github api limit being reached. See https://github.com/wmde/WikidataBuilder/issues/14 and https://github.com/wmde/WikidataBuilder/issues/15 which would make this exception nicer and allow us to pass in a READONLY Oauth token for the github API (A seperate dunny github account should be created for the builder to use).

* If puppet ever fails to run cd to /etc/puppet/manifests and do a git pull (This might solve the problem)

TODO
-----------

* If the build fails then retry
* Puppetize the adding of the fingerprints of github and gerrit

## Authors

The Wikidata Builder puppet module has been written by Adam Shorland as a [Wikimedia Germany](https://wikimedia.de) employee for the
[Wikidata project](https://wikidata.org/).

## Links

* [Wikidata Git Repo](http://git.wikimedia.org/summary/mediawiki%2Fextensions%2FWikidata)
* [WikidataBuilder User](http://git.wikimedia.org/search/?s=WikidataBuilder&r=mediawiki/extensions/Wikidata&st=AUTHOR&h=refs/heads/master)
* [Wikidata build MW extension page](https://www.mediawiki.org/wiki/Extension:Wikidata_build)
