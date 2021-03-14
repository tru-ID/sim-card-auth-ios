# How to Add SIM Card Based Mobile Authentication to your iOS App [with tru.ID](https://tru.id)

## Overview
**tru.ID** [SubscriberCheck](https://developer.tru.id/docs/subscriber-check) is a solution that offers both mobile phone number verification and SIM swap detection. SubscriberCheck achieves this by combining the workflows of [PhoneCheck](https://developer.tru.id/docs/phone-check) Service, which confirms the ownership of a mobile phone number by verifying the possession of an active SIM card with the same number and also with [SIMCheck](https://developer.tru.id/docs/sim-check) Service provides information on when a SIM card associated with a mobile phone number was last changed. 

SubscriberCheck Service is a great way to simply and combine two services under one workflow. This can be used when augmenting existing 2FA or anti-fraud workflows.

In this tutorial, we will walkthrough how to build a simple iOS application which integrates **tru.ID** [SubscriberCheck](https://developer.tru.id/docs/subscriber-check) Service to streghten your application's authentication workflow.

## Building an iOS app with SubscriberCheck

### Prerequisites
If you have not done so already;

- Download  [Xcode 12](https://developer.apple.com/xcode/)
- Register for developer account at [Apple Developer Portal](https://developer.apple.com/account/)
- Have an iPhone or an iPad with a sim card
- Have a data plan from your Network Operator


For you to integrate **tru.ID** with your own applications, you will also need:
- Knowledge of Swift language
- Experience with iOS application development 
- Experience with Xcode

If you have checked all the above, let's dive straight into adding SubscriberCheck functionality to your iOS applications.


### Set-up **tru.ID** CLI and run a development server
**tru.ID** provides [**tru.ID** CLI](https://github.com/tru-ID/cli) to quickly set a development environment which will be necessary to test sending and receiving network requests when developing your application. 

Using the CLI, we will create a Node.js development server on our machines. In a simplest sense, the development server will open up a local tunnel to this server and making it publicly accessible over the Internet. This will allow your mobile phone to access this server when connected only through cellular data. 

Therefore, the development server will act as a proxy in the middle between your mobile app and the **tru.ID** servers. This architecture and the development server nicely hides the complexities involved in developing a middle layer and reduces mobile application development times significantly.

Your production architecture should mirror this cleint/server architecture with your servers implementing necessary steps to perform on behalf of the mobile application. See [SubscriberCheck Workflow Integration](https://developer.tru.id/docs/subscriber-check/integration) to details.

First and foremost, sign up for a [**tru.ID** account](https://developer.tru.id/signup) account. The account comes with some free credits, so you can use it for testing your app against the production environment when it is ready.

If you do not have [**Node.js**](https://nodejs.org/en/download/) already, download and install it. After installing Node.js, use the following terminal command to install [**tru.ID** CLI](https://github.com/tru-ID/cli):

```bash
$ npm install -g @tru_id/cli
```

Run `tru setup:credentials` command using the command you can copy from the [**tru.ID** console](https://developer.tru.id/console):

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

Run the development server, by pointing it to the newly created project directory and configuration.

```bash
$ tru server -t --project-dir ./iosauthdemoserver
```

Check that the URL that is shown in the terminal is accessible by using your web browser. The URL will be in the format `https://{subdomain}.loca.lt`.


## Getting **tru.ID** integrated with your iOS application
If you have come this far, you already have Xcode, a **tru.ID** account and the necessary CLI and development server set-up and running. Great!

### Create an iOS Project
You can skip this step if you already have an iOS project. Otherwise;

```swift

```



### Add **tru.Id** iOS SDK
Let's add the **tru.Id** [iOS SDK](https://github.com/tru-ID/tru-sdk-ios) first. This SDK ensures that certain network calls are done on Celluar network type, which is needed to run SubcriberCheck workflow.

#### Using Swift Package Manager
Xcode integrates well with Github, and you can add Swift Packages very easily. In your Xcode, go to File -> Swift Packages -> Add Package Dependency...

Type `git@github.com:tru-ID/tru-sdk-ios.git`, and tap Next.

Xcode should be able to find the package. Check the correct version is selected.

Now that the SDK is added, we can import it when we are implementing the workflow.

#### Using CocoaPods
While we recommend using Swift Package Manager, **tru.Id** iOS SDK also supports add your dependency via CocoaPods. If you are familiar with CocoaPods and prefer using it, all you need to do is to create a Podfile and add the **tru.ID** pod spec the following way:

```
target 'MyApp' do
  pod 'tru-sdk-ios'
end
```

Make sure to run ```$ pod install``` in your project directory. After the cocoapods install all necessary pods, and configure your project, don't forget to open the workspace  rather than the project file.

You can get additional information from **tru.ID** [iOS SDK](https://github.com/tru-ID/tru-sdk-ios).


Xcode will take care of generating necessariy certificates and provisioning profiles in order to install the app on the device.

### Let's Build the User Interface

### 

### Implement the Authentication Workflow
You app may have its own ways to defining and access external service URLs, and these endpoints may be stored in configuration files such as a plist, or in your swift code. In this tutorial, we will be storing the development and production base URLs for the endpoints in a plist called TruIdService-Info.plist.

// Make sure to explain what these endpoints are 
// server endpoints that proxy requests through to the **tru.ID** API

We will add two keys one for the development endpoints and one for the production endpoints.

```
development_server_base_url
production_server_base_url

```
You must ensure to assign the correct value to the `development_server_base_url`. This value is the one you are provided from the terminal when you ran your development server.

In order to read the plist we create struct called AppConfiguration, which deals with loading the correct endpoint so we do not have to worry when we are implementing the main use cases.


## How does the workflow run?

Work in progress.


## Troubleshooting
### Mobile Data is Required

Don't forget the Subscriber Check validation requires the device to enable mobile data.

### Get in touch

If you have any questions, get in touch via [help@tru.id](mailto:help@tru.id).

