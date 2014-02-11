#!/usr/bin/env bash
#

echo --1-- Rebuilding Wikidata Build

cd /home/wdbuilder/buildscript
git checkout master
git pull origin master
git reset --hard origin/master
rm -rf /home/wdbuilder/buildscript/build/*
grunt rebuild:Wikidata_master

echo --2-- Pulling current Wikidata Repo

cd /home/wdbuilder/wikidata
git checkout master
git pull origin master
git reset --hard origin/master

echo --3-- Copying the new Wikidata build to the Repo

cd /home/wdbuilder
mkdir /home/wdbuilder/wikidata-tmp
mkdir /home/wdbuilder/wikidata-tmp/.git
cp -r /home/wdbuilder/wikidata/.git/* /home/wdbuilder/wikidata-tmp/.git
cd /home/wdbuilder/wikidata-tmp
git rm -rf *
cp -r /home/wdbuilder/buildscript/build/Wikidata_master/Wikidata/* /home/wdbuilder/wikidata-tmp
rm -rf /home/wdbuilder/wikidata
mv /home/wdbuilder/wikidata-tmp /home/wdbuilder/wikidata

echo --4-- Committing new Wikidata build

cd /home/wdbuilder/wikidata
git add *
git commit -m 'New Wikidata Build'
git push origin HEAD:refs/publish/master
git reset --hard origin/master
