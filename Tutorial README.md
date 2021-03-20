# How to Add SIM Card Based Mobile Authentication to your iOS App [with tru.ID](https://tru.id)

## Overview
**tru.ID** [SubscriberCheck](https://developer.tru.id/docs/subscriber-check) is a solution that offers both mobile phone number verification and SIM swap detection. SubscriberCheck achieves this by combining the workflows of [PhoneCheck](https://developer.tru.id/docs/phone-check) Service, which confirms the ownership of a mobile phone number by verifying the possession of an active SIM card with the same number and also with [SIMCheck](https://developer.tru.id/docs/sim-check) Service provides information on when a SIM card associated with a mobile phone number was last changed. 

SubscriberCheck Service is a great way to simply and combine two services under one workflow. This can be used when augmenting existing 2FA or anti-fraud workflows.

In this tutorial, we will walk you through how to build a simple iOS application which integrates **tru.ID** [SubscriberCheck](https://developer.tru.id/docs/subscriber-check) Service to streghten your application's authentication workflow.

The completed sample app can be found in the **tru.ID** [sim-card-auth-ios][https://github.com/tru-ID/sim-card-auth-ios/] Github repository.


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

Using the CLI, we will create a Node.js development server on our machines. This development server will open up a local tunnel and will make it publicly accessible over the Internet. 

It will act as a proxy in the middle between your mobile app and the **tru.ID** servers. This architecture and the development server nicely hides the complexities involved in developing a middle layer and reduces mobile application development times significantly.

Your production architecture should mirror this cleint/server architecture (but may be not exactly the API) with your servers implementing necessary steps to perform on behalf of the mobile application. See [SubscriberCheck Workflow Integration](https://developer.tru.id/docs/subscriber-check/integration) to details.

Ok, enough of background. Let's do it.

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

Check that the URL that is shown in the terminal is accessible by using your web browser. The URL will be in the format `https://{subdomain}.loca.lt`. This is the public accessible URL to your local development server.


### Create an iOS Project
If you have come this far,  you have created a **tru.ID** account and a development server set-up and running. Great! Let's crack on with the application. You can skip this step if you already have an iOS project. 
Otherwise;

Launch your Xcode
File -> New -> Project
In the "Choose a template for your new project" modal, select App and click Next
We will set "sim-card-auth-ios" as the Product Name, however, you can use what ever the name of your project is.
Select your Team, and make sure to assign an organization identifier using a reverse domain notation.
We will keep it simple, and use a Storyboard, UIKit App Delegate and Swift as the development language.
Uncheck "Use Code Data" if it is checked, and click Next.
Select the folder you want to store your project and click Next.
Xcode will create your project.

As you will see, it is a pretty simple project with a single ViewControlller. At this point we do not need to worry about the AppDelegate or SceneDelegate. This will be enough for us to demostrate the SubscriberCheck.

If you already have Xcode and added your developer account (Xcode->Preferences->Accounts), Xcode will take care of generating necessariy certificates and provisioning profiles in order to install the app on the device.

### Let's Build the User Interface

Let's navigate to the `Main.storyboard`. We will need to add a few basic UI components;

- Add a UILabel to display a title "Verification"
- An UIActivityIndicator (Large) to show/hide progress when we perform a SubcriberCheck
- A UILabel to indicate what the text field is for
- A UITextField so that user can enter their phone number
- A UIButton to trigger the request
- An UImageView to show whether SubcriberCheck is successful or not

All UI components are Horizontally aligned in the container using constraints. You will need to define constraints to anchor the componets as well. Start with the top label and specify the alignment between the Safe Area and the label. Do the same for all other componets, define a constraint for the Top space, and where necessary add additional constraints for width and height.

The view layout should look like this:

![Design preview](images/main_storyboard.png)

There are a couple of configuration you may want to do for these UI components.

- Text field: Select the text field, and on the Attributes Inspector, scroll to `Text Input Traits` and change the `Content Type` to `Telephone Number`. Also it would be a good idea to change the `Keyboard Type` to `Phone Pad`.
- Activity indicator: Select the activity indicator, and on the Attributes Inspector check `Hides When Stopped`

Now, we need to define our Outlets in the ViewController so that we can control the UI state. Let's select `ViewController` in Xcode, and then by using the `⌥` select `Main.storyboard` file. Both `ViewController.swift` and `Main.stroyboard` should be opened side by side.

Select the UIActivityIndicator you inserted to the storyboard, and with you `⌃` key pressed drag a connection from the storyboard to the `ViewController.swift`. Xcode will indicate possible places where you can create an Outlet. 
When you are happy release the keys and drag. You will be prompted to enter a name for the variable, type `busyActivityIndicator`.

We need to connect the UITextField, UIButton and the UIImageView as well. Let's perform the above steps for these as well respectively, and name them as follows:

phoneNumberText
nextButton
checkResults

![Design preview](images/outlets.png)

Cool! This will allow us to retrieve the phone number entered by the user, and control the state to provide feedback to the user. We now have one last thing to do related to the storyboard.

Let's also insert an action. When user taps on the Next button, we want the `ViewController`  to know that user wants to initiate the SubcriberCheck. So select the `Next` button, and with your `⌃` key pressed drag a connection from the storyboard to the `ViewController.swift`. Xcode will indicate possible places where you can create an Action. When you are happy release the keys and drag. You will be prompted to enter a name for the variable, type `next`. Xcode will insert an method with a `IBAction` annotation.

It is time to write some code to manage the UI state. The first method we are going to add is `controls(enabled: Bool)`. This method will help us show or hide `checkResults`, `busyActivityIndicator`. We will also disable the `phoneNumberTextField` is the SubcriberCheck flow is in progress.

```
// MARK: UI Controls Configure || Enable/Disable

private func controls(enabled: Bool) {

    if enabled {
        busyActivityIndicator.stopAnimating()
    } else {
        busyActivityIndicator.startAnimating()
    }

    phoneNumberTextField.isEnabled = enabled
    nextButton.isEnabled = enabled
    checkResults.isHidden = !enabled
}

private func configureCheckResults(match: Bool, noSimChange: Bool) {
    
    if match {
        let image = UIImage(systemName: "person.fill.checkmark")
        self.checkResults.image = image?.withRenderingMode(.alwaysTemplate)
        self.checkResults.tintColor = .green
    } else {
        let image = UIImage(systemName: "person.fill.xmark")
        self.checkResults.image = image?.withRenderingMode(.alwaysTemplate)
        self.checkResults.tintColor = .red
    }
}
```
We will use these methods later in the `next(_ sender: Any)` IBAction that will be triggered by the user tapping the Next button.


### Add **tru.Id** iOS SDK
It is time to focus on the code that will run the SubcriberCheck workflow. Let's start by adding the **tru.Id** [iOS SDK](https://github.com/tru-ID/tru-sdk-ios) first. This SDK ensures that certain network calls are done on Celluar network type, which is needed to run SubcriberCheck workflow.

#### Using Swift Package Manager
Xcode integrates well with Github, and you can add Swift Packages very easily. In your Xcode, go to File -> Swift Packages -> Add Package Dependency...

Type `https://github.com/tru-ID/tru-sdk-ios.git`, and tap Next.

Xcode should be able to find the package. Check the correct package version is selected.

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
 
 ### Defining Endpoints
 Your app may have its own ways to defining and access external service URLs, and these endpoints may be stored in configuration files such as a plist, or in your Swift code. In this tutorial, we will be storing the development and production base URLs in a plist called `TruIdService-Info.plist`. These server endpoints proxy some the requests through to the **tru.ID** API.
 
Create group called `util` in the project navigator
File -> New -> File
Select Property List in the dialog
Click Next
Select where you want to store the file (default selected folder should be fine)
Type `TruIdService-Info` as the file name
Click Create
 
 You should see this file created in the `util` group. Now we will add two keys to this `plist` file; one for the development endpoints and one for the production endpoints.

 ```
 development_server_base_url
 production_server_base_url

 ```
 ![Design preview](images/plist.png)
 
 You must ensure to assign the correct value to the `development_server_base_url`. This value is the one you are provided from the Terminal when you set-up and ran your development server at the begining of this tutorial. For production, you should implement your own backend and add the URL to your endpoints here in the `production_server_base_url`.

 In order to read the plist,  we create a `struct` called `AppConfiguration`, which deals with loading the correct endpoint so we do not have to worry when we are implementing the main use cases.

![Design preview](images/util_project_navigator.png)

```
import Foundation

struct AppConfiguration {
    
    let defaultConfigurationName = "TruIdService-Info"
    var configuration: [String : Any]?

    mutating func loadServerConfiguration() {
        if  let path = Bundle.main.path(forResource: defaultConfigurationName, ofType: "plist"),
            let xml = FileManager.default.contents(atPath: path)
        {
            self.configuration = (try? PropertyListSerialization.propertyList(from: xml,
                                                                              options: .mutableContainersAndLeaves,
                                                                              format: nil)) as? [String : Any]
        }
    }

    func baseURL() -> String? {
        var key = "production_server_base_url"
        #if DEBUG
        key = "development_server_base_url"
        #endif
        return configuration?[key] as? String
    }

}

```

The `AppConfiguration` struct simply reaches to the main bundle and searches for a `plist` called `TruIdService-Info`. If found, it reads the plist as a dictionary and binds that to the `configuration` variable. This URL is provided to the clients of the struct via the `baseURL() -> String?` method.

## How does the workflow run?

Work in progress.


## Troubleshooting
### Mobile Data is Required

Don't forget that the SubcriberCheck validation requires your mobile device to have data plan from your network operator and you should enable mobile data.

### Get in touch

If you have any questions, get in touch via [help@tru.id](mailto:help@tru.id).

