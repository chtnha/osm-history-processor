# OSM History Processor
The script is filtering the data-team edition, it take the replication file from `s3://osm-changeset`. The Script is running in `[osm-edit-report-service-production](https://github.com/mapbox/osm-edit-report-service)` stack and saving the file processed  on `s3://mapbox/osm-history-processor`


### Install dependency

`./install.sh && npm install`
``

###  Run the script

`npm start`

### Add more users

To add more OSM users, just add on [this file](https://github.com/mapbox/osm-history-processor/blob/master/users) the user name.