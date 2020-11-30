## UPDATE SCRIPT ###################
# find/replace: 20201110  #13 occurances

# create new dated folder 
# TERMINAL:
# mkdir ~/Dropbox\ \(Gladstone\)/Work/Projects/WikiPathways/Wikidata/20201110

# preps author info for wikidata deposition
# wpauthors.tsv comes from bash script at /home/apico/generate_wpauthors.sh on main wikipathways server (AWS)
# TERMINAL:
# ssh -i ~/aws/wp-ubuntu14-v1/wp-ubuntu14-v1-apico.pem wikipathways.org
#$ ./generate_wpauthors.sh
#$ mv wpauthors.tsv wpauthors_20201110.tsv
#$ exit
# scp -i ~/aws/wp-ubuntu14-v1/wp-ubuntu14-v1-apico.pem wikipathways.org:wpauthors_20201110.tsv ~/Dropbox\ \(Gladstone\)/Work/Projects/WikiPathways/Wikidata/20201110/.

# update wd path:
setwd("~/Dropbox (Gladstone)/Work/Projects/WikiPathways/Wikidata/20201110") 

library(tidyr)
library(dplyr)
library(stringr)
library(rdflib)
library(tibble)
library(jsonld)


#####################
# Prepare Author Data
#####################

wpa <- read.delim("wpauthors_20201110.tsv", stringsAsFactors = F) 

#clean data
## replace blank, short and email names with usernames
wpa <- wpa %>% mutate(realName = case_when(
  realName = grepl("^.{0,2}$",realName) ~ userName,
  realName = grepl("@",realName) ~ userName,
  TRUE ~ realName
))

## remove corrupted characters from names 
wpa <- wpa %>% mutate_if(is.character, function(y) {iconv(y, "latin1", "ASCII",sub='')}) 

## remove NPCs
wpa <- wpa %>% filter(!userName %in% c("NULL","MaintBot", "ReactomeTeam")
                       & !grepl("^Test", userName)
                       & !grepl("\\d+",realName)
                       & !grepl("^.{0,2}$",realName))

## Split camelcase and capitalize names
wpa <- wpa %>% mutate(realName = 
  gsub("[[:lower:]]([[:upper:]])", " \\1",realName)) %>%
  mutate(realName = tools::toTitleCase(realName))

#first authors, set editCount > global max, e.g., 1000
wpa <- wpa %>% group_by(WPID) %>% mutate(editCount = ifelse(
  firstEdit == min(firstEdit), 1000, editCount))

#calculate ordinal rank and sort
wpa <- wpa %>% group_by(WPID) %>% 
  mutate(ordinalRank = row_number(dplyr::desc(editCount))) %>% 
  mutate(userName=gsub(" ","_",userName)) %>%
  arrange(WPID, ordinalRank)

# wpa <- wpa %>%
# mutate(userName=gsub(" ","_",userName)) 

#write to tsv
write.table(wpa,"wpauthors-ranked.tsv", sep="\t", row.names=FALSE)
#wpa <- read.csv("wpauthors-ranked.tsv", sep="\t", stringsAsFactors = FALSE)


#####################
## Prepare ORCID Data
#####################

# TERMINAL:
# open ~/Dropbox\ \(Gladstone\)/Work/Projects/WikiPathways/Wikidata/orcid.csv 
browseURL("https://www.wikipathways.org/index.php?title=Special:Search&ns2=1&redirs=1&search=ORCID&limit=1000&offset=0")
# copy/paste the web page contents to overwrite csv


orcid <- read.csv("../orcid.csv", header = F, stringsAsFactors = F)
wp.orcid <- data.frame(matrix(unlist(orcid[,1]), nrow = length(orcid[,1])/3, byrow = T ),stringsAsFactors = F)
colnames(wp.orcid)<-c("userName","orcid","blah")
wp.orcid <- wp.orcid %>%
  mutate(userName = gsub("User:","",userName)) %>%
  mutate(orcid = str_match(orcid,".*(([:alnum:]{4}\\-{0,1}){4}).*")[,2]) %>%
  dplyr::select(userName,orcid)

# use SPARQL to get Wikidata ID
#install.packages("WikidataQueryServiceR")
library(WikidataQueryServiceR)

query <- 'SELECT DISTINCT ?person ?personLabel WHERE {\n  ?person wdt:P496 "XXX" .\n  SERVICE wikibase:label {\n    bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en" .\n  }\n}'

res.ls<-apply(wp.orcid, 1, function(x){
  wdq <- gsub("XXX",x['orcid'],query)
  res <- query_wikidata(wdq)
  if(nrow(res)==1){
    c(gsub("http://www.wikidata.org/entity/","",res$person),  res$personLabel)
  } else {
    c(NA, NA)
    }
})
  
res.df <- data.frame(matrix(unlist(res.ls), nrow = length(res.ls)/2, byrow = T ),stringsAsFactors = F)
colnames(res.df)<-c("wikidata","fullName")
wp.wd <- drop_na(bind_cols(wp.orcid,res.df))

orcid.df <- wpa %>% ungroup() %>%
  dplyr::select(WPID, userName, ordinalRank)

orcid.df2 <- merge(orcid.df, wp.wd, by = 'userName', sort=F)
orcid.df2 <- orcid.df2 %>% 
  mutate(userName=gsub(" ","_",userName)) %>%
  arrange(WPID, ordinalRank) 

orcid.df3 <- orcid.df2 %>%
  mutate(userName=gsub(" ","_",userName)) %>%
  distinct(userName, orcid, wikidata) 

#write to tsv
write.table(orcid.df2,"wporcid-annotated.tsv", sep="\t", row.names=FALSE)
#orcid.df2 <- read.csv("wporcid-annotated.tsv", sep="\t", stringsAsFactors = FALSE)
write.table(orcid.df3,"wporcid-annotated-unique.tsv", sep="\t", row.names=FALSE)
#orcid.df3 <- read.csv("wporcid-annotated-unique.tsv", sep="\t", stringsAsFactors = FALSE)


############################
# WRITE TTL FILES
############################

## mutate author data for RDF
wpa.ttl <- wpa %>% ungroup() %>%
  mutate(s1 = paste0("http://identifiers.org/wikipathways/",WPID)) %>%
  mutate(p1 = "dc:creator") %>%
  mutate(o1 = paste0('<http://rdf.wikipathways.org/User/',userName,'>')) %>%
  mutate(p2a = "a") %>%
  mutate(o2a = paste0('foaf:Person')) %>%
  mutate(p2b = "foaf:name") %>%
  mutate(o2b = paste0('"',realName,'"')) %>%
  mutate(p2c = "foaf:homepage") %>%
  mutate(o2c = paste0('<https://www.wikipathways.org/index.php/User:',userName,'>')) %>%
  mutate(p2d = "pq:series_ordinal") %>%
  mutate(o2d = paste0('"',ordinalRank,'"')) %>%
  dplyr::select(s1,p1,o1,p2a,o2a,p2b,o2b,p2c,o2c,p2d,o2d)

wpa.ttl2 <- wpa.ttl %>%
  group_by(s1,p1) %>% 
  summarise(o1 = paste(gsub("\"","\\\\\"",unique(o1)), sep = "", collapse = ' , '))

## mutate orcid data for RDF
orcid.ttl <- orcid.df3 %>%
  mutate(o1 = paste0('<http://rdf.wikipathways.org/User/',userName,'>')) %>%
  mutate(p2a = "owl:sameAs") %>%
  mutate(o2a = paste0('<http://www.wikidata.org/entity/',wikidata,'>')) %>%
  mutate(p2b = "dc:identifier") %>%
  mutate(o2b = paste0('<https://orcid.org/',orcid,'>')) %>%
  dplyr::select(o1,p2a,o2a,p2b,o2b)

## write out files
dir.create(paste(getwd(),"authors",sep='/'), FALSE)
sapply(wpa.ttl2$s1, function(x){
  wpid <- gsub("http://identifiers.org/wikipathways/","",x)
  filename <- paste0("authors/",wpid, ".ttl")
  writeLines(c("@prefix xsd:   <http://www.w3.org/2001/XMLSchema#> .",
               "@prefix gpml:  <http://vocabularies.wikipathways.org/gpml#> .",
               "@prefix dc:    <http://purl.org/dc/elements/1.1/> .",
               "@prefix owl: <http://www.w3.org/2002/07/owl#> .",
               "@prefix foaf:  <http://xmlns.com/foaf/0.1/> .",
               "@prefix pq: <http://www.wikidata.org/prop/qualifier/> .",
               "",
               paste0("<",x,">")
  ),filename)
  apply(wpa.ttl2[which(wpa.ttl2$s1==x),], 1, function(y){
    write(paste0("        ",y['p1'],"            ",y['o1'], " ."), filename, append = TRUE)
  })
  apply(wpa.ttl[which(wpa.ttl$s1==x),], 1, function(z){
    write("\n", filename, append = TRUE)
    write(z['o1'], filename, append = TRUE)
    write(paste0("        ",z['p2a'],"                    ",z['o2a']," ;"), filename, append = TRUE)
    write(paste0("        ",z['p2b'],"            ",z['o2b']," ;"), filename, append = TRUE)
    write(paste0("        ",z['p2d'],"            ",z['o2d']," ;"), filename, append = TRUE)
    apply(orcid.ttl[which(orcid.ttl$o1==z['o1']),], 1, function(w){
      if (!is.na(w['p2a'])){
        write(paste0("        ",w['p2a'],"           ",w['o2a']," ;"), filename, append = TRUE)
        write(paste0("        ",w['p2b'],"        ",w['o2b']," ;"), filename, append = TRUE)
      }
    })
    write(paste0("        ",z['p2c'],"        ",z['o2c']," ."), filename, append = TRUE)
  })

})

## zip authors folder; UPDATE ZIPFILE NAME
files2zip <- dir('authors', full.names = TRUE)
zip(zipfile = 'wikipathways-20201110-rdf-authors', files = files2zip)

## Upload to data.wikipathways.org:
# TERMINAL:
# ssh data.wikipathways.org 
#$ cd /var/www/wikipathways-data
#$ sudo chown -R apico:root 20201110  
#$ exit
# scp ~/Dropbox\ \(Gladstone\)/Work/Projects/WikiPathways/Wikidata/20201110/wikipathways-20201110-rdf-authors.zip data.wikipathways.org:/var/www/wikipathways-data/20201110/rdf/.

# check your work
browseURL("http://data.wikipathways.org/20201110/rdf")
