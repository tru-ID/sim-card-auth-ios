# SIM Card Based Mobile Authentication [with tru.ID]

## Overview
The tru.ID SubscriberCheck provides a solution that offers both phone number verification and SIM checking. SIM Check Service provides information on when a SIM card associated with a mobile phone number was last changed. This can be used when augmenting existing 2FA or anti-fraud workflows.

PhoneCheck on the other hand provides.

SubscriberCheck simplifies and combines the functionality offered by both PhoneCheck and SIMCheck into a single product.

## How to run this project?

### Step 1 - Have your fundamentals
You will need to follow a few steps before you can run this sample app. If you have not done so;
- Download  [Xcode 12](https://developer.apple.com/xcode/)
- Register for developer account at [Apple Developer Portal](https://developer.apple.com/account/)

You will also need a device: iPhone or an iPad with a sim card. Xcode and this sample project will take care of generating necessariy certificates and provisioning profiles in order to install the app on the device.

In order run the Subcriber Check workflow, you will need to install [**tru.ID** CLI](https://github.com/tru-ID/cli)  and run a Node.js development server.

The CLI helps you create a local development server on your machine. It opens up a local tunnel to this server and making it publicly accessible over the Internet. This will allow your mobile phone to access this server when connected only through cellular data. 

### Step 2 - Set-up tru.ID CLI and run a development server
First sign up for a [**tru.ID** account](https://developer.tru.id/signup) account, and do not forget to note down your Client Id, Client Secret and Data Residency information. The account comes with some free credits, so you can use it for testing your app against the production environment when it is ready.

In order to run the command line tools you will need [**Node.js**](https://nodejs.org/en/download/). After installing Node.js, use the following terminal command to install [**tru.ID** CLI](https://github.com/tru-ID/cli):

```bash
$ npm install -g @tru_id/cli
```

Run `tru setup:credentials` command using the credentials you have noted before from the [**tru.ID** console](https://developer.tru.id/console):

```bash
$ tru setup:credentials {client_id} {client_secret} {data_residency}
```

Install the CLI [development server plugin](https://github.com/tru-ID/cli-plugin-dev-server):

```bash
$ tru plugins:install @tru_id/cli-plugin-dev-server@canary
```

Create a new **tru.ID** project:

```bash
$ tru projects:create iOSAuthDemoServer
```

This will save a `tru.json` **tru.ID** project configuration to `./iosauthdemoserver/tru.json`.

Run the development server, pointing it to the newly created project directory and configuration.

```bash
$ tru server -t --project-dir ./iosauthdemoserver
```

Check URL that is shown in the terminal using your web browser and see if you it is accessible. The URL will be in the format `https://{subdomain}.loca.lt`.

### Step 3 - Configure the project and run
The development server is now ready waiting to accept the calls from the app you will be running through Xcode. Now, we need add the url you see on the console to a configuration file in the project.

Open the project using Xcode

Find the `TruIdService-Info.plist`

Change the value of the `` to the URL provides from the terminal.

Connect your device to you machine.

Select your device on the active Scheme



## Getting started with **tru.ID**

## Before you Begin
- Basic knowledge of Swift and iOS application development
Let's dive straight into how you can add this functionality to your iOS applications.

- Create the project
- Add the tru.id iOS SDK
- Follow the steps to create server via CLI
- Start building functionality
- Clone the app?


## Creating a New iOS Project

```swift

```

## Troubleshooting
### Mobile Data is Required

Don't forget the SubscriberCheck validation requires the device to enable mobile data.

### Get in touch

If you have any questions, get in touch via [help@tru.id](mailto:help@tru.id).

