#!/bin/sh

set -eu

accessToken=$1
projectPath=$2
if [ $3 = "true" ]; then
  deploy=true
else
  deploy=false
fi
productBranch=$4
productBuildNumber=$5

echo " \n\n === Building .jar file === \n"

# print maven's version
mvn --version

# setup Artifactory access token for Maven
mkdir -p ~/.m2
echo $accessToken > ~/.m2/settings.xml

# check if in root directory
if [ ! -d ".git" ]; then
  echo "You must be in the project's root!\n"
  exit 1
fi

# build Spark jar
echo " \n\n === Maven build === \n"
cd $projectPath
mvn -s ~/.m2/settings.xml verify

# exit script if deploy is false
if [ $deploy = false ]; then
  exit 0
fi

# deploy to Artifactory
packageVersion="1.0.$productBuildNumber"
if [ ! -z $productBranch ] && [ $productBranch != "master" ]; then
  packageVersion="$packageVersion-$productBranch"
fi

echo "deploying version: '$packageVersion'"

echo "\n ==> Deploy to Artifactory \n"

mvn -s ~/.m2/settings.xml -f pom.xml "-DnewVersion=$packageVersion" versions:set
mvn -s ~/.m2/settings.xml -f pom.xml install deploy
