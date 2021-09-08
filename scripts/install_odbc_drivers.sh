#!/bin/bash

DEBIAN_FRONTEND=noninteractive
# ODBC Connections
sudo apt-get install -y unixodbc-dev unixodbc

# SQL Server ODBC Drivers (Free TDS)
sudo apt-get install -y tdsodbc

# # PostgreSQL ODBC ODBC Drivers
sudo apt-get install -y odbc-postgresql

# # SQLite ODBC Drivers
sudo apt-get install -y libsqliteodbc

# # MySQL ODBC Drivers
sudo apt-get install -y libmyodbc


# Install SQL Server odbc 17
# download from https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15
# determine release
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

## Pick the Ubuntu version
sudo su
UBUNTU_VERSION=${UBUNTU_VERSION:-`lsb_release -sr`}
curl https://packages.microsoft.com/config/ubuntu/${UBUNTU_VERSION}/prod.list > /etc/apt/sources.list.d/mssql-release.list
exit
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql17
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc

# # MySQL ODBC Drivers
# sudo su 
# curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# sudo apt-get install -y libmyodbc