# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [1.0.1]

### Fixed
-  Support for oas3 relative server url [#380](https://github.com/3scale/3scale_toolbox/pull/380)

## [1.0.0]

### Added
- Support for Ruby 3 [#363](https://github.com/3scale/3scale_toolbox/pull/363)
- OpenAPI support for multiple flows in oauth [#368](https://github.com/3scale/3scale_toolbox/pull/368)

### Fixed
-  Apply application command: only set app key type depending on backend_version [#361](https://github.com/3scale/3scale_toolbox/pull/361)

### Changed
- Upgrade internal dependencies [#351](https://github.com/3scale/3scale_toolbox/pull/351) [#353](https://github.com/3scale/3scale_toolbox/pull/353) [#354](https://github.com/3scale/3scale_toolbox/pull/354) [#359](https://github.com/3scale/3scale_toolbox/pull/359) [#360](https://github.com/3scale/3scale_toolbox/pull/360) [#365](https://github.com/3scale/3scale_toolbox/pull/365) [#366](https://github.com/3scale/3scale_toolbox/pull/366) [#367](https://github.com/3scale/3scale_toolbox/pull/367)

## [0.20.0]

### Added
-  `3scale proxy` set of commands [#347](https://github.com/3scale/3scale_toolbox/pull/347)
-  Support stringio object as format of ResourceReader [#343](https://github.com/3scale/3scale_toolbox/pull/343)
-  Import 3scale Backend from OpenAPI spec [#340](https://github.com/3scale/3scale_toolbox/pull/340)

### Fixed
-  `verify_ssl` option on resource reader by URL [#348](https://github.com/3scale/3scale_toolbox/pull/348)
-  Reuse TCP connection against 3sscale API endpoints [#342](https://github.com/3scale/3scale_toolbox/pull/342)
-  Remove `end_user_registration_required` field from service commands [#341](https://github.com/3scale/3scale_toolbox/pull/341)

### Changed
- \[**Breaking**\] Remove deprecated `3scale update service` command [#349](https://github.com/3scale/3scale_toolbox/pull/349)

## [0.19.3]

### Added
- Add s390x to TravisCI [#338](https://github.com/3scale/3scale_toolbox/pull/338)

### Fixed
- Import OAS: reconciliate anonymous policy [#328](https://github.com/3scale/3scale_toolbox/pull/328)
- Add backends to remote cache [#333](https://github.com/3scale/3scale_toolbox/pull/333)
- Plan import/export: support product/backends model [#331](https://github.com/3scale/3scale_toolbox/pull/331)
- Enable testing logs [#337](https://github.com/3scale/3scale_toolbox/pull/337)

## [0.19.2]

### Fixed
- Fix product copy command help message [#329](https://github.com/3scale/3scale_toolbox/pull/329)

## [0.19.1]

### Fixed
- Correct keyword args delegation [#324](https://github.com/3scale/3scale_toolbox/pull/324)

## [0.19.0]

### Added
- Deprecate Ruby 2.5 [#307](https://github.com/3scale/3scale_toolbox/pull/307)

### Changed
- Docker image based on ubi8/ruby-27 [#309](https://github.com/3scale/3scale_toolbox/pull/309)
- \[**Breaking**\] Mapping rules will be replaced instead of adding missing ones [#308](https://github.com/3scale/3scale_toolbox/pull/308)

### Fixed
- Detect OAS format error [#318](https://github.com/3scale/3scale_toolbox/pull/318)

## [0.18.3]

### Added
- Enable ppc64le arch on 3scale_toolbox [#303](https://github.com/3scale/3scale_toolbox/pull/303)

### Fixed
- Fix openapi import for self managed services when production url is not passed [#304](https://github.com/3scale/3scale_toolbox/pull/304)

## [0.18.2]

### Fixed
- Product import command: make logger null stream cross-platform compatible [#290](https://github.com/3scale/3scale_toolbox/pull/290)
- Product copy command: copy methods includes description [#288](https://github.com/3scale/3scale_toolbox/pull/288)

## [0.18.1]

### Fixed
- Fix import openapi command failing when importing the same OpenAPI spec twice [#292](https://github.com/3scale/3scale_toolbox/pull/292)

## [0.18.0]

### Added
- 3scale product import and export commands [#286](https://github.com/3scale/3scale_toolbox/pull/286)
- 3scale proxy-config deploy command [#281](https://github.com/3scale/3scale_toolbox/pull/281)
- Added optional argument to openapi import command to allow setting oidc issuer type [#279](https://github.com/3scale/3scale_toolbox/pull/279)
- Product policy chain import and export commands [#270](https://github.com/3scale/3scale_toolbox/pull/270)
- Support for Ruby 2.7 [#260](https://github.com/3scale/3scale_toolbox/pull/260)

### Fixed
- Fix product copy command when the backend number exceeds one page size [#278](https://github.com/3scale/3scale_toolbox/pull/278)

## [0.17.1]

### Fixed
- When parsing oas3, fix custom ports for backend url Update service deprecated message [#265](https://github.com/3scale/3scale_toolbox/pull/265)

## [0.17.0]

### Added
- Standard way to report errors [#246](https://github.com/3scale/3scale_toolbox/pull/246)
- Proxy config export command [#244](https://github.com/3scale/3scale_toolbox/pull/244)

### Fixed
- Update service deprecated message [#238](https://github.com/3scale/3scale_toolbox/pull/238)
- Application plan import: input resource as source of truth [#245](https://github.com/3scale/3scale_toolbox/pull/245)
- Service copy command: do not copy endpoint url hosted services [#250](https://github.com/3scale/3scale_toolbox/pull/250)

## [0.16.0]

### Added
- Provide a parseable output (JSON / YAML) as optional parameter in several commands [#229](https://github.com/3scale/3scale_toolbox/pull/229)
- Backend copy command [#233](https://github.com/3scale/3scale_toolbox/pull/233)
- Product copy command [#235](https://github.com/3scale/3scale_toolbox/pull/235)

## [0.15.0]

### Added
- Allow filtering activedocs by Service ID [#225](https://github.com/3scale/3scale_toolbox/pull/225)
- OpenAPI 3 support [#226](https://github.com/3scale/3scale_toolbox/pull/226)
- Add prefix matching flag for mapping rules in import openapi command [#224](https://github.com/3scale/3scale_toolbox/pull/224)
- Add custom host header and secret token options for import openapi [#221](https://github.com/3scale/3scale_toolbox/pull/221)
- Deprecate ruby 2.4 [#232](https://github.com/3scale/3scale_toolbox/pull/232)

### Fixed
- Make activedocs apply command not set *skip_swagger_validations* on activedocs update [#227](https://github.com/3scale/3scale_toolbox/pull/227)
- copy service command copies oidc conf [#228](https://github.com/3scale/3scale_toolbox/pull/228)

## [0.14.0]

### Fixed
- Several fixes [#215](https://github.com/3scale/3scale_toolbox/pull/215) [#216](https://github.com/3scale/3scale_toolbox/pull/216) [#217](https://github.com/3scale/3scale_toolbox/pull/217)

## [0.13.0]

### Fixed
- Copy command: delete default mapping rules when service is created [#210](https://github.com/3scale/3scale_toolbox/pull/210)

### Changed
- Gemfile.lock tracked [#212](https://github.com/3scale/3scale_toolbox/pull/212)

## [0.12.4]

### Fixed
- Fix documentation on application specification evaluation order [#203](https://github.com/3scale/3scale_toolbox/pull/203)

### Changed
- Minor documentation changes [#204](https://github.com/3scale/3scale_toolbox/pull/204),
  [#205](https://github.com/3scale/3scale_toolbox/pull/205), [#206](https://github.com/3scale/3scale_toolbox/pull/206)

## [0.12.3]

### Fixed
- Verbose mode writes to stderr [#197](https://github.com/3scale/3scale_toolbox/pull/197)
- Fix gemspec file name [#198](https://github.com/3scale/3scale_toolbox/pull/198)

### Changed
- Dockerfile based on ruby-25-centos7 [#196](https://github.com/3scale/3scale_toolbox/pull/196)

## [0.12.0]

### Fix
- Application plan apply: make idempotent for hidden and published [#172](https://github.com/3scale/3scale_toolbox/pull/172)
- Create application plan: remove --end-user-required flag [#171](https://github.com/3scale/3scale_toolbox/pull/171)
- Handle remote not found error [#170](https://github.com/3scale/3scale_toolbox/pull/170)
- Copy/import metric tasks [#169](https://github.com/3scale/3scale_toolbox/pull/169)
- Make ProxyConfig promote command idempotent [#174](https://github.com/3scale/3scale_toolbox/pull/174)
- Copy service: copy activedocs idempotent [#179](https://github.com/3scale/3scale_toolbox/pull/179)
- leaking the SSO Issuer Endpoint secrets in the ActiveDocs [#180](https://github.com/3scale/3scale_toolbox/pull/180)
- Application apply: make idempotent --resume and --suspend [#185](https://github.com/3scale/3scale_toolbox/pull/185)
- Create new app if app_id exists in another service [#183](https://github.com/3scale/3scale_toolbox/pull/183)
- Pricing rules cost_per_unit as float [#187](https://github.com/3scale/3scale_toolbox/pull/187)
- Application plan import idempotent [#188](https://github.com/3scale/3scale_toolbox/pull/188)
- Import openapi: create methods process idempotent [#189](https://github.com/3scale/3scale_toolbox/pull/189)
- Import openapi: include method object description [#189](https://github.com/3scale/3scale_toolbox/pull/189)
- Impost openapi: raise error when resource is a directory [#190](https://github.com/3scale/3scale_toolbox/pull/190)
- Entities id treated as integers [#193](https://github.com/3scale/3scale_toolbox/pull/193)

### Added
- Openapi: override private base url [#168](https://github.com/3scale/3scale_toolbox/pull/168)
- Search the account by several fields [#191](https://github.com/3scale/3scale_toolbox/pull/191)
- Applications create commands add redirect url attribute [#192](https://github.com/3scale/3scale_toolbox/pull/192)
- Add licenses.xml to gem [#194](https://github.com/3scale/3scale_toolbox/pull/194)

## [0.11.0]

### Added
- Print `import openapi --help` options for file & URL formats [#143](https://github.com/3scale/3scale_toolbox/pull/143)
- Service CRUD operations [#130](https://github.com/3scale/3scale_toolbox/pull/130)
- ActiveDocs CRUD operations [#145](https://github.com/3scale/3scale_toolbox/pull/145)
- Account find command [#142](https://github.com/3scale/3scale_toolbox/pull/142)
- Import OpenApi: set the public staging prod URLs [#150](https://github.com/3scale/3scale_toolbox/pull/150)
- ProxyConfig CRUD operations [#155](https://github.com/3scale/3scale_toolbox/pull/155)
- Policy Registry (a.k.a. custom policies) copy command [#153](https://github.com/3scale/3scale_toolbox/pull/153)
- Application CRUD operations [#157](https://github.com/3scale/3scale_toolbox/pull/157)

### Changed
- Mocked integration tests removed [#146](https://github.com/3scale/3scale_toolbox/pull/146)
- Service copy command idempotent and working with service `system_name` or `id` [#164](https://github.com/3scale/3scale_toolbox/pull/164)

### Fix
- `metrics` command renamed to `metric` [#140](https://github.com/3scale/3scale_toolbox/pull/140)
- `methods` command renamed to `method` [#140](https://github.com/3scale/3scale_toolbox/pull/140)
- CI license finder check [#149](https://github.com/3scale/3scale_toolbox/pull/149)
- Application plan commands float number processing [#162](https://github.com/3scale/3scale_toolbox/pull/162)
- Application plan creation when hidden [#165](https://github.com/3scale/3scale_toolbox/pull/165)

## [0.10.0]

### Added
- Metric CRUD operations [#137](https://github.com/3scale/3scale_toolbox/pull/137)
- Method CRUD operations [#137](https://github.com/3scale/3scale_toolbox/pull/137)

### Fixed
- Remote adding validation method support master account [#138](https://github.com/3scale/3scale_toolbox/pull/138)

## [0.9.0]

### Added
- Import openapi: update url-rewritting policy [#121](https://github.com/3scale/3scale_toolbox/pull/121)
- Dockerfile: build toolbox image [#123](https://github.com/3scale/3scale_toolbox/pull/123)
- Import openapi: patch activedocs [#124](https://github.com/3scale/3scale_toolbox/pull/124)
- Export/import Application Plan limits, pricing rules and features [#132](https://github.com/3scale/3scale_toolbox/pull/132)
- Application plan CRUD operations [#134](https://github.com/3scale/3scale_toolbox/pull/134)

### Fixed
- Application plan limits and pricingrules matching rules [#119](https://github.com/3scale/3scale_toolbox/pull/119)
- Update proxy object with latest changes [#129](https://github.com/3scale/3scale_toolbox/pull/129)

## [0.8.0]

### Added
- Print usage when missing subcommand [#106](https://github.com/3scale/3scale_toolbox/pull/106)
- New swagger parser. Support vendor extensions. [#110](https://github.com/3scale/3scale_toolbox/pull/110)
- Optionally skip validation of Swagger format [#112](https://github.com/3scale/3scale_toolbox/pull/112)
- Toolbox optional verbose mode [#115](https://github.com/3scale/3scale_toolbox/pull/115)
- Update service settings based on security reqs when importing openapi [#116](https://github.com/3scale/3scale_toolbox/pull/116)
- Deprecate ruby 2.3, add ruby 2.6 support [#131](https://github.com/3scale/3scale_toolbox/pull/131)

### Changed
- When importing OAS, ActiveDoc is created by default on visible state [#109](https://github.com/3scale/3scale_toolbox/pull/109)
- Software under Apache 2.0 License [#114](https://github.com/3scale/3scale_toolbox/pull/114)

### Fixed
- Support system signals for windows systems [#113](https://github.com/3scale/3scale_toolbox/pull/113)
- Copy service set default deployment option when it is invalid in target env [#126](https://github.com/3scale/3scale_toolbox/pull/126)

## [0.7.0]

### Added
- Copy/Update: include activedocs [#97](https://github.com/3scale/3scale_toolbox/pull/97)
- Copy/Update: include pricing rules [#98](https://github.com/3scale/3scale_toolbox/pull/98)
- Copy/Update: include proxy policies [#101](https://github.com/3scale/3scale_toolbox/pull/101)
- Import OAS: push activedocs [#103](https://github.com/3scale/3scale_toolbox/pull/103)

### Changed
- In `copy service` comamnd, target system name is optional. [#100](https://github.com/3scale/3scale_toolbox/pull/100)

### Fixed
- Import OAS: fix when missing operation id in spec. [#102](https://github.com/3scale/3scale_toolbox/pull/102)

## [0.6.0]

### Added
- Manage 3scale instance with [remotes](https://github.com/3scale/3scale_toolbox/blob/v0.6.0/docs/remotes.md),  [#53](https://github.com/3scale/3scale_toolbox/pull/53)
- Global error handler.  [#73](https://github.com/3scale/3scale_toolbox/pull/73)
- Unit tests.  [#72](https://github.com/3scale/3scale_toolbox/pull/72)
- Integration tests.  [#75](https://github.com/3scale/3scale_toolbox/pull/75)
- OpenAPI 2.0 (Swagger) import command.  [#76](https://github.com/3scale/3scale_toolbox/pull/76)

### Changed

### Fixed
- On update service, only include system_name when specified in options. [#68](https://github.com/3scale/3scale_toolbox/pull/68)

## [0.5.0]

### Added
- Plugin framework. [#51](https://github.com/3scale/3scale_toolbox/pull/51)
- Enable insecure connections with a flag for all commands. [#62](https://github.com/3scale/3scale_toolbox/pull/62)
- Documentation enhacement. [#63](https://github.com/3scale/3scale_toolbox/pull/63)

### Changed
- Remove bundler development dependency specific version. [#61](https://github.com/3scale/3scale_toolbox/pull/61)

### Fixed
- Include all available attributes on copy/update service. [#64](https://github.com/3scale/3scale_toolbox/pull/64)

## [0.4.0]

### Added

- `3scale update` that updates existing service
- `3scale copy` copies `backend_version`

## [0.3.0]

### Changed
- Require Ruby >= 2.1 in the gemspec

## [0.2.2] - 2016-04-21
### Fixed
- `3scale import csv` importing mapping rules

## [0.2.1] - 2016-04-12
### Added
- `3scale copy` added new argument --target-system-name

## [0.2.0] - 2016-03-30
### Added
- `3scale copy service` can copy between different accounts

### Changed
- `3scale copy` changed arguments (from endpoint & provider key to source, see --help)

### Fixed
- `3cale copy help` now prints correct help

## [0.1.1] - 2016-03-16
### Added
- `3scale copy service` now copies Proxy and Mapping Rules

## [0.1.0] - 2016-03-11
### Added
- `3scale` command
- `3scale copy service` command to copy a service
  including its metrics, methods, application plans and their usage limits

[Unreleased]: https://github.com/3scale/3scale_toolbox/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/3scale/3scale_toolbox/releases/tag/v1.0.1
[1.0.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v1.0.0
[0.20.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.20.0
[0.19.3]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.19.3
[0.19.2]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.19.2
[0.19.1]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.19.1
[0.19.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.19.0
[0.18.3]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.18.3
[0.18.2]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.18.2
[0.18.1]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.18.1
[0.18.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.18.0
[0.17.1]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.17.1
[0.17.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.17.0
[0.16.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.16.0
[0.15.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.15.0
[0.14.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.14.0
[0.13.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.13.0
[0.12.4]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.12.4
[0.12.3]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.12.3
[0.12.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.12.0
[0.11.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.11.0
[0.10.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.10.0
[0.9.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.9.0
[0.8.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.8.0
[0.7.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.7.0
[0.6.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.6.0
[0.5.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.5.0
[0.4.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.4.0
[0.3.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.3.0
[0.2.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.2.0
[0.1.1]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.1.1
[0.1.0]: https://github.com/3scale/3scale_toolbox/releases/tag/v0.1.0
