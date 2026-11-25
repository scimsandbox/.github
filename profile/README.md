# SCIM Sandbox

[**SCIM Sandbox**](https://scimsandbox.net/) is an open-source SCIM 2.0 server, RFC 7643/7644/9865/9967 compliance validator, and interactive API playground for testing identity provisioning flows (Okta, Microsoft Entra ID, and other SCIM clients). It provides Go and Spring Boot SCIM 2.0 servers, a 550-requirement conformance validation suite, management UIs, and all the infrastructure needed to run everything locally or in Kubernetes.

> [!WARNING]
> **Data Privacy / PII**: This application is built as a sandbox. It stores SCIM request and response payloads in the database without redaction for debugging purposes. Treat it as a local or development sandbox service, not a hardened production deployment.

## Production URLs

| Service | URL |
|---|---|
| SCIM Sandbox Website | [scimsandbox.net](https://scimsandbox.net/) |
| Getting Started Guide | [scimsandbox.net/getting-started/](https://scimsandbox.net/getting-started/) |
| SCIM 2.0 Compliance Directory | [scimsandbox.net/compliance/](https://scimsandbox.net/compliance/) |
| Release News & Updates | [scimsandbox.net/news/](https://scimsandbox.net/news/) |
| SCIM Server Manager | [ui.scimsandbox.net](https://ui.scimsandbox.net/) |
| SCIM Compliance | [val.scimsandbox.net](https://val.scimsandbox.net/) |
| SCIM Playground | [val.scimsandbox.net/playground](https://val.scimsandbox.net/playground) |

## Repositories

The project is split into focused, single-responsibility repositories:

### SCIM Server

| Repository | Description |
|---|---|
| [scim-server-impl-spring](https://github.com/scimsandbox/scim-server-impl-spring) | Spring Boot SCIM 2.0 server implementation — the core API that handles SCIM requests and stores provisioning data. |
| [scim-server-impl-go](https://github.com/scimsandbox/scim-server-impl-go) | Go SCIM 2.0 server implementation — the core API that handles SCIM requests and stores provisioning data. |
| [scim-server-ui-spring](https://github.com/scimsandbox/scim-server-ui-spring) | **SCIM Server Manager** — Spring Boot management UI and API for creating workspaces, managing tokens, and inspecting SCIM traffic. |
| [scim-server-db](https://github.com/scimsandbox/scim-server-db) | Database migration bundle (Flyway) for the SCIM server database schema. |
| [scim-server-load-test](https://github.com/scimsandbox/scim-server-load-test) | k6 load-test harness for benchmarking the SCIM server under realistic traffic. |

### SCIM Validator

| Repository | Description |
|---|---|
| [scim-validator](https://github.com/scimsandbox/scim-validator) | Standalone SCIM 2.0 compliance test suite that can validate any SCIM endpoint. |
| [scim-validator-ui-spring](https://github.com/scimsandbox/scim-validator-ui-spring) | **SCIM Compliance** and **SCIM Playground** — Spring Boot UI for running the conformance suite and for exploring SCIM requests interactively. |
| [scim-validator-db](https://github.com/scimsandbox/scim-validator-db) | Database migration bundle (Flyway) for the validator results database. |

### Infrastructure & Deployment

| Repository | Description |
|---|---|
| [scim-app-local](https://github.com/scimsandbox/scim-app-local) | Docker Compose stack for running the full SCIM Sandbox locally. |
| [scim-app-k8s](https://github.com/scimsandbox/scim-app-k8s) | Kubernetes manifests and Kustomize overlays for production deployments. |
| [scim-app-policy](https://github.com/scimsandbox/scim-app-policy) | Privacy Policy and Terms of Service documents, published via GitHub Pages. |
| [scim-website](https://github.com/scimsandbox/scim-website) | Public website (`scimsandbox.net`), Getting Started guide, News, and SCIM 2.0 Compliance Directory. |

## Issues & Feature Requests

All bugs, feature requests, and general discussions are tracked centrally in the **[scim-project](https://github.com/scimsandbox/scim-project)** repository.

👉 **[Open a new issue](https://github.com/scimsandbox/scim-project/issues/new)**

Please do **not** open issues on individual module repositories — use `scim-project` so everything stays in one place.
