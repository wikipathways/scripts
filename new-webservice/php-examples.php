<html>
 <head>
  <title>PHP Examples for WikiPathways API</title>
 </head>
 <body>
<?php

  $baseIri = "http://webservice.wikipathways.org/";
  $ns1 = "http://www.wso2.org/php/xsd";
  $ns2 = "http://www.wikipathways.org/webservice";

  print "<h1>Pathway Info for WP1</h1>";
  $wp1Iri = $baseIri . "getPathwayInfo?pwId=WP1";
  $wp1Dom = DOMDocument::load($wp1Iri);

  foreach ($wp1Dom->getElementsByTagNameNS($ns1, 'pathwayInfo') as $pathwayInfo) {
      foreach ($pathwayInfo->getElementsByTagNameNS($ns2, '*') as $child) {
          echo $child->localName, ": ", $child->nodeValue, "<br>";
      }
  }

  print "<h1>Pathway History for WP1, from 2011 to Present</h1>";
  $wp1Iri = $baseIri . "getPathwayHistory?pwId=WP1&timestamp=20110101000000";
  $wp1Dom = DOMDocument::load($wp1Iri);

  foreach ($wp1Dom->getElementsByTagNameNS($ns2, 'history') as $history) {
      foreach ($history->getElementsByTagNameNS($ns2, '*') as $child) {
          echo $child->localName, ": ", $child->nodeValue, "<br>";
      }
  }

  print "<h1>All Organisms</h1>";
  $allOrganismsIri = $baseIri . "listOrganisms?format=xml";
  $allOrganismsDom = DOMDocument::load($allOrganismsIri);

  foreach ($allOrganismsDom->getElementsByTagNameNS($ns1, 'organisms') as $organism) {
      echo $organism->nodeValue, "<br>";
  }

  print "<h1>All Pathway Names for Homo sapiens</h1>";
  $allPathwaysIri = $baseIri . "listPathways?organism=Homo+sapiens";
  $allPathwaysDom = DOMDocument::load($allPathwaysIri);

  foreach ($allPathwaysDom->getElementsByTagNameNS($ns1, 'pathways') as $pathway) {
      foreach ($pathway->getElementsByTagNameNS($ns2, 'name') as $name) {
          echo $name->nodeValue, "<br>";
      }
  }

?> 
 </body>
</html>
