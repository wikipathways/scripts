###
# Test script for new WikiPathways webservice API
# author: msk (mkutmon@gmail.com)
###

import httplib2
from lxml import etree as ET

# define namespaces
namespaces = {'ns1':'http://www.wso2.org/php/xs','ns2':'http://www.wikipathways.org/webservice'}

# list organisms
h = httplib2.Http()
(resp_headers, content) = h.request("http://test2.wikipathways.org/wpi/webservicetest/webservice.php/listOrganisms", "GET")

dom = ET.fromstring(content)

# print each organism
for node in dom:
	print node.text


