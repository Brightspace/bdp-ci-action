#!/bin/sh

set -eu

accessToken=$1
projectPath=$2

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
