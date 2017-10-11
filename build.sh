#! /bin/sh

set -e
set -u

# This script is a hack to get an openbsd version of grafana.
# We repackage it this way because rebuilding the web pargs on openbsd
# seems to be a pain.

grafana_version=4.5.2
srctarball=grafana-$grafana_version.src.tar.gz
bintarball=grafana-$grafana_version.linux-x64.tar.gz

# download tarballs
curl -L -o $srctarball https://github.com/grafana/grafana/archive/v$grafana_version.tar.gz
curl -L -o $bintarball https://s3-us-west-2.amazonaws.com/grafana-releases/release/$bintarball
sha1 -c sha1sums

# build native components
tar xzf $srctarball 
mkdir -p go/src/github.com/grafana/
mv grafana-$grafana_version go/src/github.com/grafana/grafana
cd go
export GOPATH=`pwd`
cd src/github.com/grafana/grafana/
go run build.go build
cd ../../../../../

# repackage
tar xzf $bintarball 
cp go/src/github.com/grafana/grafana/bin/* ./grafana-$grafana_version/bin/
tar czf grafana-$grafana_version.openbsd-x64.tar.gz grafana-$grafana_version
rm -rf grafana-$grafana_version $srctarball $bintarball ./go
