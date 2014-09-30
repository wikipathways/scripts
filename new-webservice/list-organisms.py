###
# Test script for new WikiPathways webservice API
# author: msk (mkutmon@gmail.com)
###

import requests
import getpass
from lxml import etree as ET

# define namespaces
namespaces = {'ns1':'http://www.wso2.org/php/xs','ns2':'http://www.wikipathways.org/webservice'}

print "\n========================\nGET ORGANISM LIST\n========================\n"

# list organisms
r = requests.get('http://test2.wikipathways.org/wpi/webservicetest/?method=listOrganisms&format=xml')
dom = ET.fromstring(r.text)

# print each organism
for node in dom:
	print node.text
