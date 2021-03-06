# SIM Card Based Mobile Authentication with iOS

How to Add SIM Card Based Mobile Authentication to your iOS App with [tru.ID](https://tru.id).

[![License][license-image]][license-url]


## Before you being

You will need:

- Apple Developer Account (so that you can run this demo app on a device)
- An iOS phone with a SIM card and mobile data connection
- iOS capable IDE e.g. [Xcode 12](https://developer.apple.com/xcode/)

## Getting Started

Install the [tru.ID CLI]() and set it up using the command provided in the [tru.ID console](https://developer.tru.id/console):

```bash
$ tru setup:credentials {client_id} {client_secret} {data_residency}
```

Install the development server plugin:

```bash
$ tru plugins:install @tru_id/cli-plugin-dev-server@canary
```

Create a **tru.ID** project:

```bash
$ tru projects:create authsome-ios
```

Run the development server and take a note of the local tunnel URL:

```bash
$ tru server --project-dir ./authsome-ios
```

Clone or this repo:

```bash
$ git clone git@github.com:tru-ID/sim-card-auth-ios.git
```

Open the project with your Xcode.

Add configuration to identify the local tunnel URL of the development server  in `tru-id.plist` :

```
LOCAL_SERVER_BASE_URL="https://local.tru.com"
```

Connect your phone to your computer so it's used for running the application and run the application from your IDE.

Enter the phone number for the mobile device in the UI in the following format +{country_code}{number} e.g. `+447900123456`.  Tap "Verify my phone number" button and you will see the result of the check.

Get in touch: please email [feedback@tru.id](mailto:feedback@tru.id) with any questions.


## References

- [tru.ID example node.js server](https://github.com/tru-ID/server-example-node)
- [tru.ID docs](https://developer.tru.id/docs)

## Meta

Distributed under the MIT license. See [LICENSE][license-url] for more information.

[https://github.com/tru-ID](https://github.com/tru-ID)

[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.md
