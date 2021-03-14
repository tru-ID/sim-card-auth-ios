# SIM Card Based Mobile Authentication with iOS

This sample iOS project will help you understand the steps you should follow to integrate**tru.ID**. [tru.ID](https://tru.id)  SubscriberCheck to you applications.

[![License][license-image]][license-url]


## First Steps
You will need:

- Apple Developer Account (so that you can run this demo app on a device)
- An iOS phone with a SIM card and mobile data connection
- [Xcode 12](https://developer.apple.com/xcode/)

## Getting Started

Before you can start running the sample project, there are few things you should to set-up. First, you need to install the [tru.ID CLI](https://developer.tru.id/). This will help you create a development server up and running, which the sample app will be using to accomplish the necessary steps for SubscriberCheck set it up using the command provided in the [tru.ID console](https://developer.tru.id/console):

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

Take a note of the local tunnel URL, which will be need for configuring the sample project. 

The development server is now ready and waiting to accept calls from the app. Now, we need to download this repo, configure and run it through Xcode. 

## Clone the sample project repo
Clone this repo:

```bash
$ git clone git@github.com:tru-ID/sim-card-auth-ios.git
```


## Configure the project
Now, we need add the local tunnel url you see on the terminal to a configuration file in the project.

Open the project using Xcode

Find the `TruIdService-Info.plist`

Change the value of the ```development_server_base_url``` to the URL provided from the terminal.

```
...
<key>development_server_base_url</key>
<string>https://spotty-pig-12342.loca.lt</string>
...
```

Then connect your phone to your computer, navigate to the scheme and select as target device and run the application. Make sure your device's mobile data is enabled (doesn't have to strictly on cellular network when running this app though) 

Build and Run

When the application launches,  enter the phone number which is associated with the sim card installed in the following format +{country_code}{number} e.g. `+447900123456`.  Tap "Verify my phone number" button and you will see the result of the check.

// TODO Screenshot

Tap Next

Observer on the terminal that the calls from the application hits the development server.


// TODO Screenshot


Get in touch: please email [feedback@tru.id](mailto:feedback@tru.id) with any questions.

## References

- [tru.ID example node.js server](https://github.com/tru-ID/server-example-node)
- [tru.ID docs](https://developer.tru.id/docs)

## Meta

Distributed under the MIT license. See [LICENSE][license-url] for more information.

[https://github.com/tru-ID](https://github.com/tru-ID)

[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.md
