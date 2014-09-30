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

##################################

# define namespaces
namespaces = {'ns1':'http://www.wso2.org/php/xs','ns2':'http://www.wikipathways.org/webservice'}

# login
pswd = getpass.getpass('Password:')
auth = {'name' : username , 'pass' : pswd}
r_login = requests.get('http://test2.wikipathways.org/wpi/webservicetest/?method=login&format=xml', params=auth)
dom = ET.fromstring(r_login.text)

authentication = ''
for node in dom.findall('ns1:auth', namespaces):
	authentication = node.text

# read gpml file
f = open(gpml_file, 'r')
gpml = f.read()

# create pathway
update_params = {'auth' : username+'-'+authentication, 'gpml': gpml}
re = requests.post('http://test2.wikipathways.org/wpi/webservicetest/?method=createPathway&format=xml', params=update_params)
print re.text
