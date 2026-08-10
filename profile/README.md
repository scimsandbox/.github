# SCIM Sandbox

**SCIM Sandbox** is an open-source ecosystem for testing, validating, and experimenting with the [SCIM 2.0](https://scim.cloud/) provisioning protocol. It provides a fully functional SCIM server, a compliance validation suite, management UIs, and all the infrastructure needed to run everything locally or in Kubernetes.

> [!WARNING]
> **Data Privacy / PII**: This application is built as a sandbox. It stores SCIM request and response payloads in the database without redaction for debugging purposes. Treat it as a local or development sandbox service, not a hardened production deployment.

## Production URLs

| Service | URL |
|---|---|
| Server UI | [ui.scimsandbox.net](https://ui.scimsandbox.net/) |
| Validator UI | [val.scimsandbox.net](https://val.scimsandbox.net/) |

## Repositories

The project is split into focused, single-responsibility repositories:

### SCIM Server

| Repository | Description |
|---|---|
| [scim-server-impl-spring](https://github.com/scimsandbox/scim-server-impl-spring) | Spring Boot SCIM 2.0 server implementation — the core API that handles SCIM requests and stores provisioning data. |
| [scim-server-impl-go](https://github.com/scimsandbox/scim-server-impl-go) | Go SCIM 2.0 server implementation — the core API that handles SCIM requests and stores provisioning data. |
| [scim-server-ui-spring](https://github.com/scimsandbox/scim-server-ui-spring) | Spring Boot management UI and API for creating workspaces, managing tokens, and inspecting SCIM traffic. |
| [scim-server-db](https://github.com/scimsandbox/scim-server-db) | Database migration bundle (Flyway) for the SCIM server database schema. |
| [scim-server-load-test](https://github.com/scimsandbox/scim-server-load-test) | k6 load-test harness for benchmarking the SCIM server under realistic traffic. |

### SCIM Validator

| Repository | Description |
|---|---|
| [scim-validator](https://github.com/scimsandbox/scim-validator) | Standalone SCIM 2.0 compliance test suite that can validate any SCIM endpoint. |
| [scim-validator-ui-spring](https://github.com/scimsandbox/scim-validator-ui-spring) | Spring Boot UI for running the validator suite and browsing stored results. |
| [scim-validator-db](https://github.com/scimsandbox/scim-validator-db) | Database migration bundle (Flyway) for the validator results database. |

### Infrastructure & Deployment

| Repository | Description |
|---|---|
| [scim-app-local](https://github.com/scimsandbox/scim-app-local) | Docker Compose stack for running the full SCIM Sandbox locally. |
| [scim-app-k8s](https://github.com/scimsandbox/scim-app-k8s) | Kubernetes manifests and Kustomize overlays for production deployments. |
| [scim-app-policy](https://github.com/scimsandbox/scim-app-policy) | Privacy Policy and Terms of Service documents, published via GitHub Pages. |

## Issues & Feature Requests

All bugs, feature requests, and general discussions are tracked centrally in the **[scim-project](https://github.com/scimsandbox/scim-project)** repository.

👉 **[Open a new issue](https://github.com/scimsandbox/scim-project/issues/new)**

Please do **not** open issues on individual module repositories — use `scim-project` so everything stays in one place.
