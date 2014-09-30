###
# Test script for new WikiPathways webservice API
# author: msk (mkutmon@gmail.com)
###

import requests
from lxml import etree as ET

##################################
# variables

pathway_id = 'WP274'

##################################

# define namespaces
namespaces = {'ns1':'http://www.wso2.org/php/xs','ns2':'http://www.wikipathways.org/webservice'}

pathway = {'pwId' : pathway_id}
r = requests.get('http://test2.wikipathways.org/wpi/webservicetest/?method=getPathwayInfo&format=xml', params=pathway)
dom = ET.fromstring(r.text)

# print pathway info details
# ET.QName(child).localname return tag name without namespace
for node in dom.findall('ns1:pathwayInfo', namespaces):
	for child in node:
		print ET.QName(child).localname + ": " + child.text


