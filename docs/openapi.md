## Import API definition to 3scale from OpenAPI definition

To create a new 3scale product or 3scale backend, you can import the OpenAPI definition from a local file or a URL.

The `import openapi` command has the following format:

```
3scale import openapi [opts] -d <destination> <OAS>
```

### Table of contents

* [Import API definition to 3scale from OpenAPI definition](#import-api-definition-to-3scale-from-openapi-definition)
   * [Table of contents](#table-of-contents)
   * [OpenAPI document sources](#openapi-document-sources)
      * [filename in path](#filename-in-path)
      * [URL](#url)
      * [Standard input stream stdin](#standard-input-stream-stdin)
   * [Supported OpenAPI spec version and limitations](#supported-openapi-spec-version-and-limitations)
   * [Importing 3scale Backend from OpenAPI](#importing-3scale-backend)
   * [OpenAPI import rules](#openapi-import-rules)
      * [Idempotent](#idempotent)
      * [Product name](#product-name)
      * [Private Base URL](#private-base-url)
      * [3scale Methods](#3scale-methods)
      * [3scale Mapping Rules](#3scale-mapping-rules)
      * [Authentication](#authentication)
      * [ActiveDocs](#activedocs)
      * [3scale Policies](#3scale-policies)
      * [3scale Deployment Mode](#3scale-deployment-mode)
   * [Minimum required OAS doc](#minimum-required-oas-doc)
   * [Usage](#usage)

### OpenAPI document sources

The OpenAPI document `<OAS>` can be read from different sources:

* filename in path
* URL
* `stdin`

#### filename in path

Allowed formats are `json` and `yaml`. The format is automatically detected from filename __extension__.

```shell
$ 3scale import openapi -d <destination> /path/to/your/spec/file.[json|yaml|yml]
```

#### URL

Allowed formats are `json` and `yaml`. The format is automatically detected from URL's path __extension__.

```shell
$ 3scale import openapi -d <destination> http[s]://domain/resource/path.[json|yaml|yml]
```

#### Standard input stream `stdin`

Command line parameter for the openapi resource is `-`.

Supported OAS document formats are `json` and `yaml`. The format is automatically detected internally by the parser.

```shell
$ tool_to_read_openapi_from_source | 3scale import openapi -d <destination> -
```

### Supported OpenAPI spec version and limitations

* [OpenAPI __2.0__ specification](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/2.0.md) (f.k.a. __swagger__)
* [OpenAPI __3.0.2__ specification](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md) with some limitations:
  * Only first `servers[0].url` element in `servers` list parsed as *private base url*. As OpenAPI specification`basePath` property, `servers[0].url` URL's base path component will be used.
  * Toolbox will *not* parse servers in path item or operation objects.
  * Supported security schemes: apiKey, oauth2 (any flow type).

### Importing 3scale Backend

The OpenAPI import command can be used to target a 3scale backend.
The command line option `--backend` enables this feature.
The OAS itself won't be stored in 3scale but a 3scale backend, private base URL,
mapping rules and methods will be created.

Some existing command options don't make sense when creating a backend.
Valid options are listed here:

```shell
$ 3scale import openapi -d <remote> --backend <OAS>
OPTIONS
       --backend                                  Create backend API from OAS
    -d --destination=<value>                      3scale target instance.
                                                  Format:
                                                  "http[s]://<authentication>@3scale_domain"
    -o --output=<value>                           Output format. One of:
                                                  json|yaml
       --override-private-base-url=<value>        Custom private base URL
                                                  the private URLs
       --prefix-matching                          Use prefix matching instead
                                                  of strict matching on
                                                  mapping rules derived from
                                                  openapi operations
       --skip-openapi-validation                  Skip OpenAPI schema
                                                  validation
    -t --target_system_name=<value>               Target system name
```

The backend's private endpoint is read from the OpenAPI `servers[0].url` field.
You can override this using this `--override-private-base-url=<value>` command option.
When the OpenAPI doc does not contain `servers[0].url` and private base url is not provided,
the command will fail.

### OpenAPI import rules

#### Idempotent

The command was designed to be idempotent. It can be executed multiple times without changing the result. If the command fails for some unexpected temporary issue, like a network outage, it is safe to re-run as many times as necessary. It is designed to be run from CI/CD system expecting to be run multiple times with the same parameters.

#### Product name

OpenAPI import command can be used to create a new product or to update an existing product.
The default product name for the import is specified by the `info.title` in the OpenAPI definition.
However, you can override this product name using this `--target_system_name=<NEW NAME>` command option.

#### Private Base URL

Private base URL is read from OpenAPI `servers[0].url` field.
You can override this using this `--override-private-base-url=<value>` command option.

#### 3scale Methods

Each OpenAPI defined operation will translate in one 3scale method at product level.
The method name is read from the [operationId](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#operationObject) field of the operation object.

#### 3scale Mapping Rules

Each OpenAPI defined operation will translate in one 3scale mapping rule at product level.
Previously existing mapping rules will be replaced by those imported from the OpenAPI.

OpenAPI [paths](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#pathsObject) object provides mapping rules *Verb* and *Pattern* properties. 3scale methods will be associated accordingly to the [operationId](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#operationObject)

*Delta* value is hard-coded to `1`.

By default, *Strict matching* policy is being configured. Matching policy can be switched to **Prefix matching** with the `--prefix-matching` command option.

#### Authentication

Just one top level security requirement supported.
Operation level security requirements are not supported.

Supported security schemes: `apiKey`, `oauth2` (any flow type).

For the `apiKey` security scheme type:
* *credentials location* will be read from the OpenAPI [in](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#security-scheme-object) field of the security scheme object.
* *Auth user key* will be read from the OpenAPI [name](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#security-scheme-object) field of the security scheme object.

Partial example of OpenAPI (3.0.2) with `apiKey` security requirement

```yaml
---
openapi: "3.0.2"
security:
  - petstore_api_key: []
components:
  securitySchemes:
    petstore_api_key:
      type: apiKey
      name: api_key
      in: header
```

For the `oauth2` security scheme type:
* *credentials location* is hard-coded to `headers`.
* *OpenID Connect Issuer Type* defaults to `rest` and can be overridden using this `--oidc-issuer-type=<value>` command option.
* *OpenID Connect Issuer* is not read from OpenAPI. Since 3scale requires that the issuer URL must include a *client secret*, the issue must be set using this `--oidc-issuer-endpoint=<value>` command option.
* *OIDC AUTHORIZATION FLOW* is read from the [flows](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#security-scheme-object) field of the security scheme object.

Partial example of OpenAPI (3.0.2) with `oauth2` security requirement

```yaml
---
openapi: "3.0.2"
security:
    - petstore_oauth:
      - write:pets
      - read:pets
  components:
    securitySchemes:
      petstore_oauth:
        type: oauth2
        flows:
          clientCredentials:
            tokenUrl: http://example.org/api/oauth/dialog
            scopes:
              write:pets: modify pets in your account
              read:pets: read your pets
```

When OpenAPI does not specify any security requirements:
* The product is considered as an "Open API"
* `default_credentials` 3scale policy will be added (also called as `anonymous_policy`)
* The command option `--default-credentials-userkey` is required and the command will fail if not provided.

#### ActiveDocs

A 3scale ActiveDoc will be created (or updated if previously existed).
The activedoc object will be associated to the 3scale product being imported out of the OpenAPI.

#### 3scale Policies

* When there is no security requirement spec, `default_credentials` 3scale policy will be added (also called as `anonymous_policy`).
* RH-SSO/Keycloak role check policy set for `oauth2` security requirements.
* *URL rewriting* policy set when public and private base paths (not URLs) do not match. Public and private base paths matches by default, but any or both of them can be overridden using `--override-public-basepath` and `--override-private-basepath=<value>` command options.

#### 3scale Deployment Mode

By default, the configured 3scale deployment mode will be `APIcast 3scale managed`.
However, when `--production-public-base-url` or `--staging-public-base-url` (or both) command options are found,
the toolbox will configure the product with `APIcast self-managed` deployment mode.

### Minimum required OAS doc

In [OAS 3.0.2](https://github.com/OAI/OpenAPI-Specification/blob/main/versions/3.0.2.md#oasDocument), the minimum **valid** OpenAPI document just contains `info` and `paths` fields.

For instance:

```yaml
---
openapi: "3.0.2"
info:
  title: "some title"
  description: "some description"
  version: "1.0.0"
paths:
  /pet:
    get:
      operationId: "getPet"
      responses:
        405:
          description: "invalid input"
```

However, with this OpenAPI document, there is critical 3scale configuration lacking and must be provided to the toolbox for a working 3scale configuration:
* `Private Base URL` passing `--override-private-base-url=<value>` command option
* Since the document does not contain any security requirement, the toolbox expects some default user key as credentials passing `--default-credentials-userkey <USER-KEY>` command option.

```shell
3scale import openapi -d <remote> --default-credentials-userkey=<user-key> --override-private-base-url=<value> <oas>
```

To avoid extra command line options, the minimum valid OpenAPI document should include the `servers[0].url` field and basic security requirements for `apiKey`. For instance:

```yaml
---
openapi: "3.0.2"
info:
  title: "some title"
  description: "some description"
  version: "1.0.0"
servers:
  - url: https://petstore.swagger.io/v1
paths:
  /pet:
    get:
      operationId: "getPet"
      responses:
        405:
          description: "invalid input"
security:
  - petstore_api_key: []
components:
  securitySchemes:
    petstore_api_key:
      type: apiKey
      name: user_key
      in: query
```

With this OpenAPI document, the toolbox does not need extra command options to have a working 3scale product.

```shell
3scale import openapi -d <remote> <oas>
```

*Note*: 3scale still requires creating the application key, but this is out of scope of this toolbox command.

### Usage

```shell
NAME
    openapi - Import API defintion in OpenAPI specification from a local file or URL

USAGE
    3scale import openapi [opts] -d <destination>
    <spec> (/path/to/your/spec/file.[json|yaml|yml] OR
    http[s]://domain/resource/path.[json|yaml|yml])

DESCRIPTION
    Using an API definition format like OpenAPI, import to your 3scale API
    directly from a local OpenAPI spec compliant file or a remote URL

OPTIONS
       --activedocs-hidden                        Create ActiveDocs in hidden
                                                  state
       --backend                                  Create backend API from OAS
       --backend-api-host-header=<value>          Custom host header sent by
                                                  the API gateway to the
                                                  backend API
       --backend-api-secret-token=<value>         Custom secret token sent by
                                                  the API gateway to the
                                                  backend API
    -d --destination=<value>                      3scale target instance.
                                                  Format:
                                                  "http[s]://<authentication>@3scale_domain"
       --default-credentials-userkey=<value>      Default credentials policy
                                                  userkey
    -o --output=<value>                           Output format. One of:
                                                  json|yaml
       --oidc-issuer-endpoint=<value>             OIDC Issuer Endpoint
       --oidc-issuer-type=<value>                 OIDC Issuer Type (rest,
                                                  keycloak)
       --override-private-base-url=<value>        Custom private base URL
       --override-private-basepath=<value>        Override the basepath for
                                                  the private URLs
       --override-public-basepath=<value>         Override the basepath for
                                                  the public URLs
       --prefix-matching                          Use prefix matching instead
                                                  of strict matching on
                                                  mapping rules derived from
                                                  openapi operations
       --production-public-base-url=<value>       Custom public production
                                                  URL
       --skip-openapi-validation                  Skip OpenAPI schema
                                                  validation
       --staging-public-base-url=<value>          Custom public staging URL
    -t --target_system_name=<value>               Target system name
```
