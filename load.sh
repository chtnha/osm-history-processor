#!/bin/bash
set -eu
url="https://s3.amazonaws.com/osm-changesets/day/000/001/"
OHPBUCKET=s3://mapbox/osm-history-processor
SRCBUCKET=s3://osm-changesets

for i in $(seq $1 $2)
do	
    if (($i<10)); then
    	i=00$i
    fi
    if (($i<100)) && (($i>=10)); then
    	i=0$i
    fi
    echo "Getting file $url$i.osc.gz"
	curl $url$i.osc.gz -o "$i.osc.gz"

	echo "$i.osc.gz to temp.osm"
	osmconvert $i.osc.gz -o=temp.osm

	echo "Filter by user"
	rm users
	wget https://raw.githubusercontent.com/mapbox/osm-history-processor/master/users
	users=("$(cat users)")
	IFS="," read -ra STR_ARRAY <<< "$users"
	for j in "${STR_ARRAY[@]}"
	  do
	    osmfilter temp.osm --keep=@user=$j -o=$j.osm
	done

	rm temp.osm
	tar -zcvf $i.tar.gz *.osm

	echo "upload S3"
	aws s3 cp  $i.tar.gz $OHPBUCKET/day/000/001/
	rm *.gz
	rm *.osm
done