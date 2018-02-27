---
categories:
- support-bundle-yaml-specs
date: 2018-01-17T23:51:55Z
description: Get the version of the docker server
index: docs
title: docker.version
weight: "100"
gradient: "purpleToPink"
---

## docker.version

Get the version of the docker server


```yaml
specs:
  - docker.version:
      output_dir: /docker/version
```

    
### Outputs


- `docker_version.raw` - Raw output

- `docker_version.json` - JSON output

- `docker_version.human` - Human-readable output

    
<br>
{{< note title="Shared Parameters" >}}
This spec also inherits all of the required and optional [Shared Parameters](/api/support-bundle-yaml-specs/shared/)
{{< /note >}}
    
    