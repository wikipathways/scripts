# WikiPathways Data Release

## Associated repos

- https://github.com/wikipathways/java-bots
- https://github.com/wikipathways/scripts

We talk about this content in the following issue:
https://github.com/wikipathways/GPML2RDF/issues/57

## To run a monthly WikiPathways Data Release

```
cd /data/projects/wikipathways-data/public_html
<fill-in-the-path>/wikipathways-data-release "$(pwd)" > >(tee out.log) 2> >(tee err.log >&2)
```

or

```
<fill-in-the-path>/wikipathways-data-release "/data/projects/wikipathways-data/public_html" > >(tee out.log) 2> >(tee err.log >&2)
```

## Deployment
### wmcloud
Dashboard: https://horizon.wikimedia.org/project/ (requires login)

Instance:
 - Name: data, VCPUs: 4, 	Disk: 20GB, RAM: 8GB

Volume:
 - Name: data.wikipathways.org, Size: 21GiB, Status: In-use, Type: standard, Attach: /dev/sdb on data, Zone: nova, Bootable: No, Encrypted: No 

See [full docs](https://docs.google.com/document/d/1evmOaC58oFvX38Lv81BpUWKbXW--ASic9U5R9tRrTfM/edit#) (requires login)

### Toolforge
The directory `/data/projects/wikipathways-data/public_html` is an existing directory on wikipathways-data.toolforge.org, and it's intended to hold the WikiPathways release data. This has been replaced by the wmcloud service above, but is still around in case of backup.
