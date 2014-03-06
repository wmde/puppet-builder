Wikidata Builder
=========

This repo contains a puppet module to automate the building of the Wikidata product!

This module installs all dependencies, clones a few repos and sets up a cron!

##Automated build process

####Generating a build

* The build is triggered by a [cronjob](https://github.com/addshore/puppet/blob/master/files/wikidatabuilder/cron.sh) on the a [wikidata-builderN](https://wikitech.wikimedia.org/wiki/Nova_Resource:Wikidata-build) instance at 10:00 AM (UTC) each day.
* The build script from https://github.com/wmde/WikidataBuilder is used to generate the build.
* The build is then pushed to a new commit in the [Wikidata repository](https://gerrit.wikimedia.org/r/#/admin/projects/mediawiki/extensions/Wikidata) on Gerrit.

####Testing the build

* After a new commit was made, [WikidataJenkins](http://wikidata-jenkins.wmflabs.org/ci/) runs PHPUnit tests for [client](http://wikidata-jenkins.wmflabs.org/ci/job/wikidata-build-client-tests/) and [repo](http://wikidata-jenkins.wmflabs.org/ci/job/wikidata-build-repo-tests/) with experimental mode enabled and for [client](http://wikidata-jenkins.wmflabs.org/ci/job/wikidata-build-client-tests-nonexperimental/) and [repo](http://wikidata-jenkins.wmflabs.org/ci/job/wikidata-build-repo-tests-nonexperimental/) with experimental set to false.
* If the tests pass, WikidataJenkins verifies the change on Gerrit and votes +2 on CodeReview.
* The +2 makes [WMF Jenkins](https://integration.wikimedia.org/zuul/) run a gate-submit job which again runs some PHPUnit tests and then merges the change into master.

####Deployment to beta

* Once the change is merged into master, [beta-code-update](http://integration.wikimedia.org/ci/job/beta-code-update) job starts and deploys the new Wikidata build to https://wikidata.beta.wmflabs.org.
* This takes about 15 minutes and can be verified by checking the version of the Wikidata build on http://wikidata.beta.wmflabs.org/wiki/Special:Version.

####Browsertesting the new build on beta

* Whenever a new build is merged into master a [job for running browsertests](https://wikidata-jenkins.wmflabs.org/ci/job/wikidata-browsertests-sauce/) is triggered.
* The job is delayed by 30 minutes to give beta-code-updater enough time to finish deployment on beta.
* This job runs a set of [browsertests](https://git.wikimedia.org/tree/mediawiki%2Fextensions%2FWikibase/c4062fdfe5c4349411092a8baf4486454b0a5d59/tests%2Fbrowser) (Selenium) targeting the new build on beta.
* [Saucelabs](https://saucelabs.com/) is used to run the tests in Firefox on Linux.
* One can follow the progress of the tests on https://saucelabs.com/u/wikidata-saucelabs.
* TODO: An email is sent to wikidata-bugs@lists.wikimedia.org when failures occur.

Installation
-----------

1. Create an instance on labs, call it something like "wikidata-builderN".

2. Run Puppet
> puppetd -tv

3. On wikitech > Manage Instances > Instance > Configure > enable "role::puppet::self".

4. Run Puppet
> puppetd -tv

5. As root clone this repo as a puppet module
> git clone https://github.com/wmde/puppet-builder.git /etc/puppet/modules/wdbuilder

6. On wikitech (If not already done) > Manage Puppet Groups > Project > Add class > "wdbuilder::builder".

7. On wikitech > Manage Instances > Configure Instance > Tick the wdbuilder::builder class

8. Run Puppet (expect a failure when cloning the gerrit repo)
> puppetd -tv

9. Make a public / private key for the wdbuidler user
> ssh-keygen -t rsa

10. Copy the public key to gerrit from /home/wdbuilder/.ssh for the WikidataBuilder user

11. Run Puppet (this time it should work)
> puppetd -tv

12. Run the bash script as wdbuilder and see if it all works!
> /data/wdbuilder/cron.sh

Troubleshooting
-----------

* If puppet ever fails to run cd to /etc/puppet/manifests and do a git pull (This might solve the problem)

TODO
-----------

* If the build fails then retry

## Authors

The Wikidata Builder puppet module has been written by Adam Shorland as a [Wikimedia Germany](https://wikimedia.de) employee for the
[Wikidata project](https://wikidata.org/).

## Links

* [Wikidata Git Repo](http://git.wikimedia.org/summary/mediawiki%2Fextensions%2FWikidata)
* [WikidataBuilder User](http://git.wikimedia.org/search/?s=WikidataBuilder&r=mediawiki/extensions/Wikidata&st=AUTHOR&h=refs/heads/master)
* [Wikidata build MW extension page](https://www.mediawiki.org/wiki/Extension:Wikidata_build)
