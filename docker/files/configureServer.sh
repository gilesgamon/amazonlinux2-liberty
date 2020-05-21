#!/bin/bash

#cp $WLP_HOME/usr/servers/defaultServer/server.xml /tmp/server.xml

#Modify the entries in server.xml to add the HOST access to internet
content='   <featureManager>\
       <feature>ssl-1.0</feature>\
     </featureManager>\
     <keyStore id=\"defaultKeyStore\" password=\"Liberty\" \/>'

sed '/<!-- To access/i\'"$content" $WLP_HOME/usr/servers/defaultServer/server.xml > /tmp/s1.xml

sed '15 a \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \  host = "\*" ' /tmp/s1.xml > $WLP_HOME/usr/servers/defaultServer/server.xml

rm -rf /tmp/s1.xml