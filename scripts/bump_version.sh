#!/bin/bash
# Usage: ./scripts/bump_version.sh 1.0.1 2
# Sets version to 1.0.1+2 in pubspec.yaml
VERSION=$1
BUILD=$2
sed -i "s/^version: .*/version: $VERSION+$BUILD/" pubspec.yaml
echo "Version set to $VERSION+$BUILD"
