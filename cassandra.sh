#!/bin/bash
line="CREATE KEYSPACE physiqual WITH replication = {'class':'SimpleStrategy', 'replication_factor' : 1};"
echo $line | pbcopy

docker run -it --rm --name cassmgmt --link cassandra1:cassmgmt cassandra cqlsh cassandra1
