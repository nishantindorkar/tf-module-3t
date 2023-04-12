#!/bin/bash
sudo apt update -y
sudo apt-get install openjdk-11-jdk -y
sudo apt update -y
sudo wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.87/bin/apache-tomcat-8.5.87.tar.gz
sudo tar -xvzf apache-tomcat-8.5.87.tar.gz
sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/student.war -P apache-tomcat-8.5.87/webapps/
sudo wget https://s3-us-west-2.amazonaws.com/studentapi-cit/mysql-connector.jar -P apache-tomcat-8.5.87/lib/
sudo sh apache-tomcat-8.5.87/bin/catalina.sh stop
sudo sh apache-tomcat-8.5.87/bin/catalina.sh start