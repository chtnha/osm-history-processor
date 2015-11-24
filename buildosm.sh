#!/bin/bash
set -eu
OHPBUCKET=s3://mapbox/osm-history-processor
SRCBUCKET=s3://osm-changesets

echo "Getting id from latest replication day file..."
aws s3 cp --quiet $SRCBUCKET/state/day .
DAYLATEST=$(cat day)

echo "Getting latest replication day file..."
aws s3 cp --quiet $SRCBUCKET/day/${DAYLATEST:0:3}/${DAYLATEST:3:3}/${DAYLATEST:6:3}.osc.gz .

echo "${DAYLATEST:6:3}.osc.gz to ${DAYLATEST:6:3}.osm"
osmconvert ${DAYLATEST:6:3}.osc.gz -o=temp.osm

echo "Filter by user"
users=("$(cat users)")
IFS="," read -ra STR_ARRAY <<< "$users"
for j in "${STR_ARRAY[@]}"
  do
    osmfilter temp.osm --keep=@user=$j -o=$j.osm
done
rm temp.osm
rm day
tar -zcvf ${DAYLATEST:6:3}.tar.gz *.osm

echo upload S3
aws s3 cp  ${DAYLATEST:6:3}.tar.gz $OHPBUCKET/day/${DAYLATEST:0:3}/${DAYLATEST:3:3}/
rm *.gz
rm *.osm