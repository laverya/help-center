---
date: "2018-05-01T19:00:00Z"
title: "Deliver a private Docker Image"
description: "Use Ship to provide proxied access to your private Docker images"
weight: "30109"
categories: [ "Get Started with Ship" ]
index: "guides/ship"
type: "chapter"
gradient: "console"
icon: "replicatedShip"
---

{{< note title="Part 6 Of A Series" >}}
This is part 6 of a guide that walks through creating a sample application in Replicated Ship. If you haven't followed the previous sections of this guide, go back to [iterating locally](../iterate-locally) before following this guide.
{{< /note >}}

With the [recommended repository layout](../iterate-locally) set up, the next step is to push a private image to the [Replicated Registry](/docs/registry/security) and use Ship's built-in licensing to give your end customers access.


{{< linked_headline "Logging in to the Registry" >}}

{{< note title="Replicated Registry Only" >}}
Ship supports pulling images from other registries like ECR, GCR, Docker Hub, Quay, etc. For the
sake of simplicity, this guide is limited to pushing and pulling directly to and from the Replicated Registry
(registry.replicated.com). Furthermore, while Ship supports delivering image archive bundles for airgapped installations,
we'll only cover online installations here.
{{< /note >}}

You can log to the registry using your username and password you to log into [console.replicated.com](https://console.replicated.com) or [vendor.replicated.com](https://vendor.replicated.com):

```bash
$ docker login registry.replicated.com
Username: ...
Password:
```

The docker CLI will prompt you for your username and password.

{{< linked_headline "Tag and Push" >}}

You'll want tag your images using your ship app "slug" as the registry namespace. For example, if your app is called `Super CI`, then your app slug might be something like `superci`. You can find the app slug under the "Settings" tab in [the vendor console](https://vendor.replicated.com).

Assuming you've already got an image in a private Docker Hub (or ECR, GCR, etc.) repo at `superci/superci-enterprise-api:1.0.1`, you'lll want to retag it and push it to the registry.

```bash
docker pull superci/superci-enterprise-api:1.0.1
docker tag superci/superci-enterprise-api:1.0.1 registry.replicated.com/superci/api:1.0.1
docker push registry.replicated.com/superci/api:1.0.1
```


{{< linked_headline "Create Image Pull Secret" >}}

Next, you can add an image pull secret to your Kubernetes assets. Assuming you've set up the [recommended git repo](../iterate-locally), you can add this file to the `base/` directory. Otherwise you can use an [inline asset](/docs/ship/assets/inline). We'll create a secret called `imagepullsecret-example`.

```yaml
apiVersion: v1
kind: Secret
type: kubernetes.io/dockerconfigjson
metadata:
  name: imagepullsecret-example
stringData:
  .dockerconfigjson: |
    {
      "auths": {
        "registry.replicated.com": {
          "auth": "{{repl (Base64Encode (print (Installation "license_id") ":" (Installation "license_id")))}}",
          "email": "fake@fake.com",
          "username": "{{repl Installation "license_id"}}",
          "password": "{{repl Installation "license_id"}}"
        }
      }
    }
```

This example uses additional `Installation` template functions to pull in the customer and installation IDs, which
serve to authenticate your end customer to the registry.

{{< linked_headline "Pull Private Images" >}}

Now that you have an image pull secret, you can schedule your private images by referencing the Replicated Registry tag directly, and adding a reference to the `imagePullSecret` we created above.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: superci-api
spec:
  imagePullSecrets:
    - imagepullsecret-example
  containers:
    - name: api
      image: registry.replicated.com/superci/superci-enterprise-api:1.0.1
```

Note that this example uses a `Pod` for brevity, in production you'll probably want a `Deployment`, as demonstrated [elsewhere in this guide](/guides/kubernetes-with-ship/create-a-release#assets).

{{< linked_headline "Test your release" >}}

Next, its time to test this and make sure everything is working. Since we'll be interacting with the Ship Vendor SaaS services, we'll need to add a few parameters to our Makefile to properly template in the `customer_id` and `installation_id` license keys. You can grab these fields from the install script you got in [console.replicated.com](https://console.replicated.com), and add them to the `run-local` and `run-local-headless` tasks. The lines to add are

```makefile
	    --customer-id <your customer id> \
	    --installation-id <your installation id> \
```

For example, `run-local` might look like:

```makefile
run-local: clean-assets lint-ship
	mkdir -p tmp
	cd tmp && \
	$(SHIP) app \
	    --runbook $(PATH)/ship.yaml  \
	    --set-github-contents $(REPO):/base:master:$(PATH) \
	    --set-github-contents $(REPO):/scripts:master:$(PATH) \
	    --set-channel-icon $(ICON) \
	    --set-channel-name $(APP_NAME) \
	    --customer-id <your customer id> \
	    --installation-id <your installation id> \
	    --log-level=off
	@$(MAKE) print-generated-assets
```

When you `kubectl apply -f` your output YAML, you should see the new `api` pod created and--assuming your image works--it should be running. If you see an `ImagePullBackoff` in the `kubectl get pods` output, you should double check the example resources.

#### Note

If you're not using the [starter repo to iterate locally](../iterate-locally), you can ignore this section and
promote the release normally, adding `inline` assets for the `Secret` and `Pod`.

{{< linked_headline "Next Steps" >}}

You can now transparently deliver your private images alongside your Kubernetes YAML. End Customers will only have access to pull your images until their license keys expire.

Now that you've got a feel for Ship basics, its time to take [a deep dive into Ship features](../explore-features).
