#!/usr/bin/env bash

# Get the date at the start of the script for use in the commit msg
now="$(date +'%d/%m/%Y %H-%M')"

echo --1-- Rebuilding Wikidata Build

# Make sure the WikidataBuilder is up to date
cd /home/wdbuilder/buildscript
git checkout master
git reset --hard origin/master
git pull origin master
# Forcefully remove all of the old build
rm -rf /home/wdbuilder/buildscript/build/*
# Rebuild Wikidata
grunt rebuild:Wikidata_master

# Only continue if the build returned "0" success
build_exit_value=$?
if [ "${build_exit_value}" -eq "0" ] ; then

	echo --2-- Pulling current Wikidata Repo

	# Checkout the current master of Wikidata!
	# If we dont do this our .git will be wrong and things get messy
	cd /home/wdbuilder/wikidata
	git checkout master
	git pull origin master
	git reset --hard origin/master

	echo --3-- Copying the new Wikidata build to the Repo

	# Make a temporary folder for our new build
	cd /home/wdbuilder
	mkdir /home/wdbuilder/wikidata-tmp
	# Copy the .git from the Wikidaat repo over to our tmp folder
	mkdir /home/wdbuilder/wikidata-tmp/.git
	cp -r /home/wdbuilder/wikidata/.git/* /home/wdbuilder/wikidata-tmp/.git
	cd /home/wdbuilder/wikidata-tmp
	# Force remove everything from the git index
	git rm -rf *
	# Copy all files created from the build into our new folder
	cp -r /home/wdbuilder/buildscript/build/Wikidata_master/Wikidata/* /home/wdbuilder/wikidata-tmp
	# Remove the old Wikidata folder and copy our new one over
	rm -rf /home/wdbuilder/wikidata
	mv /home/wdbuilder/wikidata-tmp /home/wdbuilder/wikidata

	echo --4-- Committing new Wikidata build

	# Add all files to the commit and commit to gerrit!
	cd /home/wdbuilder/wikidata
	git add *
	git commit -m "New Wikidata Build - $now"
	git push origin HEAD:refs/publish/master
	git reset --hard origin/master

else

	# TODO retry after a certain ammount of time?
	echo "Build exited with a bad error code...."

fi