#!/bin/bash

#create certificate template based on configuration from conf.ini
cd /cert-tools && create-certificate-template -c  /cert-tools/conf.ini 

rm -f /etc/data/unsigned_certificates/*
rm -f /etc/data/blockchain_certificates/*

# generate certificates using certificate template json file and user csv file in sample_data/rosters/  
cd /cert-tools && instantiate-certificate-batch -c /cert-tools/conf.ini 


#Start bitcoind
bitcoind -daemon 

sleep 1m

bitcoin-cli getinfo

#Create  issuing address inside the cert-issuer container
issuer=`bitcoin-cli getnewaddress`
sed -i.bak "s/<issuing-address>/$issuer/g" /etc/cert-issuer/conf.ini
bitcoin-cli dumpprivkey $issuer > /etc/cert-issuer/pk_issuer.txt

#Generate and print fake bitcoin money in cert-issuer container

bitcoin-cli generate 101
bitcoin-cli getbalance

#Send money to cert issuer
bitcoin-cli sendtoaddress $issuer 5

cert-issuer -c /etc/cert-issuer/conf.ini

exit 0