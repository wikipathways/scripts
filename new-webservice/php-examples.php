<html>
 <head>
  <title>PHP Test</title>
 </head>
 <body>
<?php

  $baseIri = "http://www.wikipathways.org/wpi/webservicetest/";
  $ns1 = "http://www.wso2.org/php/xsd";
  $ns2 = "http://www.wikipathways.org/webservice";

  print "<h1>Pathway Info for WP1</h1>";
  $wp1Iri = $baseIri . "?pwId=WP1&method=getPathwayInfo&format=xml";
  $wp1Dom = DOMDocument::load($wp1Iri);

  foreach ($wp1Dom->getElementsByTagNameNS($ns1, 'pathwayInfo') as $pathwayInfo) {
      foreach ($pathwayInfo->getElementsByTagNameNS($ns2, '*') as $child) {
          echo $child->localName, ": ", $child->nodeValue, "<br>";
      }
  }

  print "<h1>Pathway History for WP1, from 2011 to Present</h1>";
  $wp1Iri = $baseIri . "?pwId=WP1&timestamp=20110101000000&method=getPathwayHistory&format=xml";
  $wp1Dom = DOMDocument::load($wp1Iri);

  foreach ($wp1Dom->getElementsByTagNameNS($ns2, 'history') as $history) {
      foreach ($history->getElementsByTagNameNS($ns2, '*') as $child) {
          echo $child->localName, ": ", $child->nodeValue, "<br>";
      }
  }

  print "<h1>All Organisms</h1>";
  $allOrganismsIri = $baseIri . "?method=listOrganisms&format=xml";
  $allOrganismsDom = DOMDocument::load($allOrganismsIri);

  foreach ($allOrganismsDom->getElementsByTagNameNS($ns1, 'organisms') as $organism) {
      echo $organism->nodeValue, "<br>";
  }

  print "<h1>All Pathway Names for Homo sapiens</h1>";
  $allPathwaysIri = $baseIri . "?organism=Homo+sapiens&method=listPathways&format=xml";
  $allPathwaysDom = DOMDocument::load($allPathwaysIri);

  foreach ($allPathwaysDom->getElementsByTagNameNS($ns1, 'pathways') as $pathway) {
      foreach ($pathway->getElementsByTagNameNS($ns2, 'name') as $name) {
          echo $name->nodeValue, "<br>";
      }
  }

?> 
 </body>
</html>
