# Kauppa

[![Swift Package Manager](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)]()
[![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Twitter: @hellonaamio](https://img.shields.io/badge/contact-@hellonaamio-blue.svg?style=flat)](https://twitter.com/hellonaamio)

**Kauppa** is an open source set of microservices for creating and managing your own store-front. Comparable in features to _Magento_, _Shopify_, and _WooCommerce_, **Kauppa** builds on the similar concepts and pushes further with modern, scalable architecture, and extensibility. 

## Quick Start

To start straight away, you can get the official [**Docker** image](https://hub.docker.com/r/naamio/kauppa/):

```bash
docker run -itd --name=kauppa -p 8090:8090 naamio/kauppa:latest
```

This will run a single, monolithic build of Kauppa, with its API accessible from port 8090. All of the services are bundled in to the single image. 

You can go a long way with the single monolithic build, but it's not how we intended it to be used. For extra power, you should consider [reading the docs](https://naamio.cloud/projects/kauppa/manual/deploying) on how to deploy a service cluster.

For autoscaling, dynamic security, and deep learning-based analytics, consider trying out our [managed cloud provisioning](https://naamio.cloud), which enables all of these features, and is fully migratable, so you won't be stuck with the managed service if you decide to bring Kauppa in-house.

## Security

We experimented with a few approaches to security. Originally Kauppa was based on a monolithic marketplace service for coffee, written in Java, and then in Go. It had a rather complex, albeit powerful single sign-on service supporting it. However, as we worked with more and more partners in the community who needed control of their own data, and access to the code, we moved much of the system into two separate projects: Arusha, and Kauppa. 

Kauppa is intended to be decentralized and load balanced on a cluster. Arusha is the single-sign on we use to manage authentication and role-based access. You can use whatever you want. We developed Kauppa to have near-zero understanding of users or roles, to keep it agnostic, unopinionated, and flexible enough to work anywhere. 

This means it's inherently insecure in so far as anyone can access and change data in a default instance of Kauppa, and so security should be managed elsewhere. For us, it's managed with [Kubernetes](https://kubernetes.io) on a cluster, with [Arusha](https://github.com/Omnijar/arusha), keeping it entirely open source. Other organizations may want to use their existing SSO infrastructure and RBAC solutions. Kauppa supports **OAuth2** and **OpenID Connect** to ensure flexibility, but we don't push a specific solution onto the community.

If you want security, but want to keep life simple, you can choose [our managed service](https://naamio.cloud) instead, which includes security-as-a-service, and enables you to retain ownership of your Kauppa instance.

## Documentation

With a growing number of organizations using **Kauppa**, we're currently in the process of working closely with the community to add new features and improvements in regular updates. **Kauppa** has been built to work naturally with [Naamio](https://naamio.cloud/projects/naamio) to provide store-front extensions to **Naamio** web applications, but it can be used with any application platform. You can read more in the [official docs](https://naamio.cloud/projects/kauppa/manual).

The documentation covers the REST API, with an update underway to provide the Functions-as-a-Service (FaaS) API. These are provided on a language, by language, basis, and therefore will be provided iteratively as each language FaaS implementation is considered mature. Our priority is for JavaScript / npm support to pass the test first, and others to come later. 

We use Swift and Rust internally, and we're already looking at Go and Python as priority options.

## Licensing

**Kauppa** matches existing Naamio products by using the [MIT License](https://opensource.org/licenses/MIT), with specific clauses to protect the Naamio community and cloud infrastructure provisioning.

## References:

 - **Building:** For more detail about building Kauppa, see `docs/build.md`
 - **Design:** For the overall design, see `docs/core`
 - **Services:** For documentation of individual services, see `docs/services`