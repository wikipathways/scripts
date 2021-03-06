###
# Test script for new WikiPathways webservice API
# author: msk (mkutmon@gmail.com)
###

import requests
import getpass
from lxml import etree as ET

##################################
# variables

username = 'Mkutmon'
gpml_file = 'test.gpml'
basis_url = 'http://pvjs.wikipathways.org/wpi/webservicetest/'

##################################

# define namespaces
namespaces = {'ns1':'http://www.wso2.org/php/xsd','ns2':'http://www.wikipathways.org/webservice'}

# login
pswd = getpass.getpass('Password:')
auth = {'name' : username , 'pass' : pswd}
r_login = requests.get(basis_url + 'login', params=auth)
dom = ET.fromstring(r_login.text)

authentication = ''
for node in dom.findall('ns1:auth', namespaces):
	authentication = node.text

# read gpml file
f = open(gpml_file, 'r')
gpml = f.read()

# create pathway
update_params = {'gpml': gpml, 'auth' : authentication, 'username': username}
re = requests.post(basis_url + 'createPathway', params=update_params)
print re.text
