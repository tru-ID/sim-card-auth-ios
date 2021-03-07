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
- Have an iPhone or an iPad with a sim card
- Have a data plan from your Network Operator

Xcode and this sample project will take care of generating necessariy certificates and provisioning profiles in order to install the app on the device.

### Step 2 - Set-up tru.ID CLI and run a development server
For us to run the Subcriber Check workflow, you will also need to install [**tru.ID** CLI](https://github.com/tru-ID/cli)  and run a Node.js development server.

The CLI helps you create a local development server on your machine. It opens up a local tunnel to this server and making it publicly accessible over the Internet. This will allow your mobile phone to access this server when connected only through cellular data. 

First sign up for a [**tru.ID** account](https://developer.tru.id/signup) account, and do not forget to note down your Client Id, Client Secret and Data Residency information. The account comes with some free credits, so you can use it for testing your app against the production environment when it is ready.

Download and install [**Node.js**](https://nodejs.org/en/download/) if you do not have it already. After installing Node.js, use the following terminal command to install [**tru.ID** CLI](https://github.com/tru-ID/cli):

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

Make sure your device's mobile data is enabled (doesn't have to strictly on cellular network when running this app though) 

Build and Run

When the application launches, enter your phone number which is associated with the sim card

Tap Next

Observer on the terminal that the calls from the application hits the development server.


## Getting **tru.ID** integrated with your iOS application

### Before you Begin
If you have come this far, you already have Xcode, a tru.ID account and the necessary CLI and development server set-up and running. For you to integrate tru.ID with your own applications, you will need:

- Knowledge of Swift language
- Experience with iOS application development 
- Xcode

If so, let's dive straight into adding Subscriber Check functionality to your iOS applications.

### Create an iOS Project
If you already have an iOS project, you can skip this step. Otherwise;

```swift

```

### Add tru.Id iOS SDK
Let's add the tru.Id iOS SDK first. This will SDK ensures that certain network calls are done on celluar network type, which is need to run Subcriber Check workflow.

Go to File -> Swift Packages -> Add Package Dependency...

Type `git@github.com:tru-ID/tru-sdk-ios.git`, and tap Next.

Xcode should be able to find the package. Check the correct version is selected.

Now that the SDK is added, we can import it when we are implementing the workflow.

### Add tru.Id endpoints
You app may have its own ways to defining and access external service URLs, and these endpoints may be stored in configuration files such as a plist, or in your swift code. In this tutorial, we will be storing the development and production base URLs for the endpoints in a plist called TruIdService-Info.plist.

We will add two keys one for the development endpoints and one for the production endpoints.

```
development_server_base_url
production_server_base_url

```
You must ensure to assign the correct value to the `development_server_base_url`. This value is the one you are provided from the terminal when you ran your development server.

In order to read the plist we create struct called AppConfiguration, which deals with loading the correct endpoint so we do not have to worry when we are implementing the main use cases.

## How does the workflow run?



## Troubleshooting
### Mobile Data is Required

Don't forget the Subscriber Check validation requires the device to enable mobile data.

### Get in touch

If you have any questions, get in touch via [help@tru.id](mailto:help@tru.id).

