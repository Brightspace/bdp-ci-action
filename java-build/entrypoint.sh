#!/bin/sh

set -eu

echo " \n\n === Building .jar file === \n"

# print maven's version
mvn --version

# check if in root directory
if [ ! -d ".git" ]; then
  echo "You must be in the project's root!\n"
  exit 1
fi

# build Spark jar
echo " \n\n === Maven build === \n"
cd spark
mvn verify
