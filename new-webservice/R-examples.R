## Install (if needed) and load required packages
# For more help, try http://technistas.com/2012/06/11/using-rest-apis-from-r/
#install.packages("RCurl", "XML")

library("RCurl")
library("XML")

## List all organisms on WikiPathways ##
organismsString = getURL("http://webservice.wikipathways.org/listOrganisms")
organismsDom = xmlRoot(xmlTreeParse(organismsString))

organismNodes = xmlElementsByTagName(organismsDom, "organisms", TRUE)

for(node in organismNodes) {
	print(xmlValue(node)) #Print the organism name to the screen
}

## Find all pathways for the 'apoptosis' keyword ##
pathwaysString = getURL("http://webservice.wikipathways.org/findPathwaysByText?query=apoptosis")
pathwaysDom = xmlRoot(xmlTreeParse(pathwaysString))

# Find the result nodes
resultNodes = xmlElementsByTagName(pathwaysDom, "result", TRUE)
# Print the pathway name, species and url for each result
for(node in resultNodes) {
	children = xmlChildren(node, addNames= TRUE)
	url = xmlValue(children$url)
	name = xmlValue(children$name);
	species = xmlValue(children$species);
	
	print(paste(name, " (", species, "): ", url, sep=""))
}
