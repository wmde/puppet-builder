#!/usr/bin/env bash
#

echo Rebuilding Wikidata Build
cd /home/wdbuilder/buildscript
grunt rebuild:Wikidata_master

echo Pulling current Wikidata Repo
cd /home/wdbuilder/wikidata
git pull origin master

echo Copying the new Wikidata build to the Repo
cd /home/wdbuilder
mkdir /home/wdbuilder/wikidata2
cp -r /home/wdbuilder/buildscript/build/Wikidata_master/Wikidata/* /home/wdbuilder/wikidata2
mkdir /home/wdbuilder/wikidata2/.git
cp -r /home/wdbuilder/wikidata/.git/* /home/wdbuilder/wikidata2/.git
rm -rf /home/wdbuilder/wikidata
mv /home/wdbuilder/wikidata2 /home/wdbuilder/wikidata

echo Committing new Wikidata build
cd /home/wdbuilder/wikidata
git add *
git commit -m 'New Wikidata Build'
#TODO push