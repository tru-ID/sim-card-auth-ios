# How to Add SIM Card Based Mobile Authentication to your iOS App [with tru.ID](https://tru.id)

## Overview
**tru.ID** [SubscriberCheck](https://developer.tru.id/docs/subscriber-check) is a solution that offers both mobile phone number verification and SIM swap detection. SubscriberCheck achieves this by combining the workflows of [PhoneCheck](https://developer.tru.id/docs/phone-check) Service, which confirms the ownership of a mobile phone number by verifying the possession of an active SIM card with the same number and also with [SIMCheck](https://developer.tru.id/docs/sim-check) Service provides information on when a SIM card associated with a mobile phone number was last changed. 

SubscriberCheck service is a great way to simply and combine two services under one workflow. This can be used when augmenting existing 2FA or anti-fraud workflows.

In this tutorial, you will walk you through how to build a simple iOS application which integrates **tru.ID** [SubscriberCheck](https://developer.tru.id/docs/subscriber-check) service to streghten your application's authentication workflow.

## Building an iOS app with SubscriberCheck

### Prerequisites
If you have not done already;

- Download  [Xcode 12](https://developer.apple.com/xcode/)
- Register for developer account at [Apple Developer Portal](https://developer.apple.com/account/)
- Have an iPhone or an iPad with a sim card
- Have a data plan from your Network Operator


In order to integrate **tru.ID** with your own applications, you will also need:
- Knowledge of Swift language
- Experience with iOS application development 
- Experience with Xcode

If you have checked all the above, let's dive straight into adding SubscriberCheck functionality to your iOS applications.


### Set-up **tru.ID** CLI and Run a Development Server
**tru.ID** provides [**tru.ID** CLI](https://github.com/tru-ID/cli) to quickly set a development environment which will be necessary to test sending and receiving network requests when developing your application. 

Using the CLI, you will create a Node.js development server on our machines. This development server will open up a local tunnel and will make it publicly accessible over the Internet. 

It will act as a proxy in the middle between your mobile app and the **tru.ID** servers. This architecture and the development server nicely hides the complexities involved in developing a middle layer and reduces mobile application development times significantly.

Your production architecture should mirror this cleint/server architecture (but may not be the same API) with your servers implementing necessary steps to perform on behalf of the mobile application. See [SubscriberCheck Workflow Integration](https://developer.tru.id/docs/subscriber-check/integration) to details.

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
If you have come this far,  you have created a **tru.ID** account and a development server set-up and running. Great! Let's get cracking on with the application. You can skip this step if you already have an iOS project. Otherwise;

* Launch your Xcode
* File -> New -> Project
* In the "Choose a template for your new project" modal, select App and click Next
* Set "sim-card-auth-ios" as the Product Name, however, you can use what ever the name of your project is
* Select your Team, and make sure to assign an organization identifier using a reverse domain notation
* Keep it simple, and use a Storyboard, UIKit App Delegate and Swift as the development language
* Uncheck "Use Code Data" if it is checked, and click Next
* Select the folder you want to store your project and click Next

Xcode will create your project. As you will see, it is a pretty simple project with a single ViewControlller. At this point you do not need to worry about the AppDelegate or SceneDelegate. This will be enough for us to demostrate the SubscriberCheck.

If you already have Xcode and added your developer account (Xcode->Preferences->Accounts), Xcode will take care of generating necessariy certificates and provisioning profiles in order to install the app on the device.

### Let's Build the User Interface

Navigate to the `Main.storyboard`. you need to add a few UI components to receive input, and provide feedback from the user;

- Add a UILabel to display a title "Verification"
- An UIActivityIndicator (Large) to show/hide progress when you perform a SubcriberCheck
- A UILabel to indicate what the text field is for
- A UITextField so that user can enter their phone number
- A UIButton to trigger the request
- An UImageView to show whether SubcriberCheck is successful or not

All UI components are Horizontally aligned in the container using constraints. You will also need to define constraints to anchor the componets as well. Start with the top label and specify the alignment between the Safe Area and the label. Do the same for all other componets, define a constraint for the Top space, and where necessary add additional constraints for width and height.

The view layout should look like this:

![Main Storyboard](tutorial-images/main_storyboard.png)

There are a couple of configuration you may want to do for these UI components.

- Text field: Select the text field, and on the Attributes Inspector, scroll to `Text Input Traits` and change the `Content Type` to `Telephone Number`. Also it would be a good idea to change the `Keyboard Type` to `Phone Pad`.
- Activity indicator: Select the activity indicator, and on the Attributes Inspector check `Hides When Stopped`
- UIImageView: Select the UIImageView, and on the Attributes Inspector, scroll to Drawing, and check `Hidden`

Now, you need to define our Outlets in the ViewController so that you can control the UI state. Let's select `ViewController` in Xcode, and then by using the `⌥` select `Main.storyboard` file. Both `ViewController.swift` and `Main.stroyboard` should be opened side by side.

Select the UIActivityIndicator you inserted to the storyboard, and with you `⌃` key pressed drag a connection from the storyboard to the `ViewController.swift`. Xcode will indicate possible places where you can create an Outlet. 
When you are happy release the keys and drag. You will be prompted to enter a name for the variable, type `busyActivityIndicator`.

you need to connect the UITextField, UIButton and the UIImageView as well. Let's perform the above steps for these as well respectively, and name them as follows:

- phoneNumberText
- nextButton
- checkResults

![Outlets](tutorial-images/outlets.png)

Cool! This will allow us to retrieve the phone number entered by the user, and control the state to provide feedback to the user. you now have one last thing to do related to the storyboard.

Let's also insert an action. When user taps on the Next button, you want the `ViewController`  to know that user wants to initiate the SubcriberCheck. So select the `Next` button, and with your `⌃` key pressed drag a connection from the storyboard to the `ViewController.swift`. Xcode will indicate possible places where you can create an Action. When you are happy release the keys and drag. You will be prompted to enter a name for the variable, type `next`. Xcode will insert an method with a `IBAction` annotation.

It is time to write some code to manage the UI state. The first method you are going to add is `controls(enabled: Bool)`. This method will help us show or hide `checkResults`, `busyActivityIndicator`. you will also disable the `phoneNumberTextField` is the SubcriberCheck flow is in progress.

```swift
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
you will use these methods later in the `next(_ sender: Any)` IBAction that will be triggered by the user tapping the Next button.


### Add **tru.Id** iOS SDK
It is time to focus on the code that will run the SubcriberCheck workflow. Let's start by adding the **tru.Id** [iOS SDK](https://github.com/tru-ID/tru-sdk-ios) first. This SDK ensures that certain network calls are done on Celluar network type, which is needed to run SubcriberCheck workflow.

#### Using Swift Package Manager
Xcode integrates well with Github, and you can add Swift Packages very easily. In your Xcode, go to File -> Swift Packages -> Add Package Dependency...

Type `https://github.com/tru-ID/tru-sdk-ios.git`, and tap Next.

Xcode should be able to find the package. Check the correct package version is selected. Now that the SDK is added, you can import it when you are implementing the workflow.

#### Using CocoaPods
While you recommend using Swift Package Manager, **tru.Id** iOS SDK also supports add your dependency via CocoaPods. If you are familiar with CocoaPods and prefer using it, all you need to do is to create a Podfile and add the **tru.ID** pod spec the following way:

```
target 'MyApp' do
  pod 'tru-sdk-ios'
end
```

Make sure to run ```$ pod install``` in your project directory. After the cocoapods install all necessary pods, and configure your project, don't forget to open the workspace  rather than the project file.

You can get additional information from **tru.ID** [iOS SDK](https://github.com/tru-ID/tru-sdk-ios).
 
 ### Defining Endpoints
 Your app may have its own ways for defining and access external service URLs, and these endpoints may be stored in configuration files such as a plist, or in your Swift code. In this tutorial, you will be storing the development and production base URLs in a plist called `TruIdService-Info.plist`. These server endpoints proxy some of the requests through to the **tru.ID** API.
 
Create group called `util` in the Project Navigator
File -> New -> File
Select Property List in the dialog
Click Next
Select where you want to store the file (default selected folder should be fine)
Type `TruIdService-Info` as the file name
Click Create
 
 You should see this file created in the `util` group. Now you will add two keys to this `plist` file; one for the development endpoints and one for the production endpoints.

 ```
 development_server_base_url
 production_server_base_url

 ```
 ![Plist](tutorial-images/plist.png)
 
 You must ensure to assign the correct value to the `development_server_base_url`. This value is the one you are provided from the Terminal when you set-up and ran your development server at the begining of this tutorial. For production, you should implement your own backend and add the URL to your endpoints here in the `production_server_base_url`.

 In order to read the plist,  you create a `struct` called `AppConfiguration`, which deals with loading the correct endpoint so you do not have to worry when you are implementing the main use cases.

![Project Navigation](tutorial-images/util_project_navigator.png)

```swift
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

### It's All About the Network
It is time to create a new group called `service` in the Project Navigator. you will implement Model layer classes, structs, protocols and enums necessary in this folder and files. Note that, none of the files in this group should be importing `UIKit`.

Create Swift file in the `service` group called `SessionEndpoint.swift`. In this file, you will define a protocol called `Endpoint` and a enum of `NetworkError` and a class which implements the protocol.  Let's define the protocol `Endpoint` and `NetworkError` enum as in the following in this file.

```swift
import Foundation

protocol Endpoint {
    var baseURL: String { get }
    func makeRequest<U: Decodable>(urlRequest: URLRequest,
                     handler: @escaping (Result<U, NetworkError>) -> Void)
    
    func createURLRequest(method: String,
                          url: URL,
                          payload:[String : String]?) -> URLRequest
}

enum NetworkError: Error {
    case invalidURL
    case connectionFailed(String)
    case httpNotOK
    case noData
}
```
The purpose of  `Endpoint` protocol is to hide implementation details from the clients of this protocol. It has two methods and a variable `baseURL`. It represents one REST API endpoint. You can implement this protocol using URLSession, or with Alamofire. For the purposes of this tutorial, you will keep it simple and implement the protocol using URLSession.

Now implement a class called `SessionEndpoint` with in the `SessionEndpoint.swift` file. This is our implementation of simple network requests using URLSession.

```swift
final class SessionEndpoint: Endpoint {

    let baseURL: String
    private let session: URLSession

    init() {
        var configuration = AppConfiguration()
        configuration.loadServerConfiguration()
        baseURL = configuration.baseURL()!//Fail early so that you know there is something wrong
        session = SessionEndpoint.createSession()
    }

    private static func createSession() -> URLSession {

        let configuration = URLSessionConfiguration.ephemeral //you do not want OS to cache or persist
        configuration.allowsCellularAccess = true
        configuration.waitsForConnectivity = true
        configuration.networkServiceType = .responsiveData

        return URLSession(configuration: configuration)
    }
    
    // MARK: Protocol Implementation
    func makeRequest<U: Decodable>(urlRequest: URLRequest,
                     handler: @escaping (Result<U, NetworkError>) -> Void) {
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in

            if let error = error {
                handler(.failure(.connectionFailed(error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                handler(.failure(.connectionFailed("HTTP not OK")))
                return
            }

            guard let data = data else {
                handler(.failure(.noData))
                return
            }

            print("Reponse: \(String(describing: String(data: data, encoding: .utf8)))")

            if let dataModel = try? JSONDecoder().decode(U.self, from: data) {
                    handler(.success(dataModel))
                return
            }
        }

        task.resume()
    }

    func createURLRequest(method: String, url: URL, payload:[String : String]?) -> URLRequest {

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = method

        if let payload = payload {
            let jsonData = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            urlRequest.httpBody = jsonData
        }

        return urlRequest
    }
}
```

The `init()` method of the class loads a base URL from the `AppConfiguration` which you defined earlier. It will return an URL either for a development server or a production server depending on the build scheme. The final line of the `init()` creates a URLSession using a private static method. Note that `createSession()` method creates a configuration which doesn't cache or persist network related information; it is `ephemeral` for additional security.

The rest of the file contains the `Endpoint` protocol implementation. First method `makeRequest<>..` creates a data task using the URLRequest provided and initates the call. When the reponse is received, the method calls the `handler` closure for success or failure cases. If data exists and there are no error scenarios, then it attempts to decode the data to the model type provided.

`Result<>` generic type refers to a model object and an `Enum` which provides error cases. Fairly simple.

The `createURLRequest(..)` method receives three parameters; HTTP method name, the URL and an optional payload if the request is a POST request, for instance. The method returns a `URLRequest` object, which is then used by the `makeRequest<>..` method during the execution of the workflow.

There is nothing extra-ordinary going on.

### Model
It is now time to define our model object which will hold the information about the results of a SubscriberCheck. 

Create a Swift file called `SubscriberCheck` in the `service` group, and implement a struct with the same name as below:
```swift
import Foundation

// Response model based on https://developer.tru.id/docs/reference/api#operation/create-subscriber-check
struct SubscriberCheck: Codable {
    let check_id: String?
    let check_url: String?
    let status: SubcriberCheckStatus?
    let match: Bool?
    let no_sim_change: Bool?
    let charge_amount: Int?
    let charge_currency: String?
    let created_at: String?
    let snapshot_balance: Int?
    let _links: Links?
}

enum SubcriberCheckStatus: String, Codable {
    case ACCEPTED
    case PENDING
    case COMPLETED
    case EXPIRED
    case ERROR
}

struct Links: Codable {
    let `self`: [String : String]
    let check_url: [String : String]
}
```
Note that, you are using the response model provided by the **tru-ID** [REST API](https://developer.tru.id/docs/reference/api#operation/create-subscriber-check) documentation as basis for this struct. In a real life scenarios, your architecture and production servers may expose a different REST response model. It is for you to decide. It is important that `SubscriberCheck` implements the `Codable` protocol as this will help `JSONSerialization.data(..)` decode the json response to the `SubscriberCheck` easily. 

### Implement the Use Case and the Workflow
Now that you have defined the user interface and defined the network request/response mechanics, let's bridge the two and implement our business logic. In this section, you will define a protocol for our primary use case, and implement the SubscriberCheck workflow. Ultimately, the View layer of our application is concern about what the user is going to request. At this layer, you shouldn't be concerned about "How" it is going to be done. Since you are only concerned with SubscriberCheck, a simple `Subscriber` protocol which defines a function to receive a phone number and provide a closure for the SubscriberCheck results should be sufficient. 

Create Swift file in the `service` group called `SubscriberCheckService.swift`. In this file, define the `Subscriber` protocol as the following:

```swift
protocol Subscriber {
    func check(phoneNumber: String,
               handler: @escaping (Result<SubscriberCheck, NetworkError>) -> Void)
}

```

you will later define a variable of `Subscriber` type in our `ViewController.swift` later. This is how the View layer will talk to the Model layer.

Now you are ready to implement the business logic. Create a class called `SubscriberCheckService` in the `SunscriberCheckService` which implements the `Subscriber` protocol.

```swift
final class SubscriberCheckService: Subscriber {
    let path = "/subscriber-check"
    let endpoint: Endpoint
        
    init(){
        self.endpoint = SessionEndpoint()
    }
}
```
`SubscriberCheckService` uses a concrete implementation of `Endpoint` protocol. In our case, this is `SessionEndpoint` which defined in the previous sections. This class will make our life easy to execute the part of the workflow which requires making network requests.

It is time talk about the SubscriberCheck workflow before you dive into the coding. The workflow has 3 steps:

- Create a SubscriberCheck
- Request the SubscriberCheck URL using the **tru.ID** iOS SDK
- Retrieve the SubscriberCheck Results

The following sequence diagram shows each step.

![SubscriberCheck Workflow](tutorial-images/workflow.png)

Let's first define 3 methods which will help us stitch the above steps.

First, you need to make a POST request to the development/production server [see initial set-up](#set-up-truid-cli-and-run-a-development-server). This call can be made over any type of network (cellular/wifi). The  server should return a SubscriberCheck URL. Add the following method to the `SubscriberCheckService` class.

```swift

private func createSubscriberCheck(phoneNumber: String,
                                     handler: @escaping (Result<SubscriberCheck, NetworkError>) -> Void) {
    let urlString = endpoint.baseURL + path

    guard let url = URL(string: urlString) else {
        handler(.failure(.invalidURL))
        return
    }

    let phoneNumberDict = ["phone_number" : phoneNumber]
    let urlRequest = endpoint.createURLRequest(method: "POST", url: url, payload: phoneNumberDict)
    endpoint.makeRequest(urlRequest: urlRequest, handler: handler)
}

```
This method receives a phone number, constructs the full URL using the baseURL and the subcriber check path which is defined by the development server. Again note that this may be different for you. It is up to you to define who your production REST API will be.

Then you create a payload (simply the phone number), and create a `URLRequest` using the `endpoint.createURLRequest(..)` method. And then you use the `makeRequest(..)` method of the endpoint and pass the `urlRequest` and the handler.

you need to request the URL which will be returned by the `createSubscriberCheck(..)`. However, this call needs to be made by the **tru-ID** SDK. Let's create a helper method called `requestSubscriberCheckURL(..)`:

```swift
private func requestSubscriberCheckURL(subscriberCheckURL: String,
                                       handler: @escaping () -> Void) {

    let tru = TruSDK()

    tru.openCheckUrl(url: subscriberCheckURL) { (something) in
        handler()
    }
}
```
Do not forget to import the `TruSDK`.

```swift
import TruSDK
```
The SDK will ensure that this call will be made over the cellular network. When the `openCheckUrl(..)` calls the closure, you call the `handler` as well.

In order to help us on the third steps, you need to define one more method called `retrieveSubscriberCheck(..)` as follows:

```swift
private func retrieveSubscriberCheck(checkId: String,
                                     handler: @escaping (Result<SubscriberCheck, NetworkError>) -> Void) {

    let urlString = endpoint.baseURL + path + "/" + checkId

    guard let url = URL(string: urlString) else {
        handler(.failure(.invalidURL))
        return
    }

    let urlRequest = endpoint.createURLRequest(method: "GET", url: url, payload: nil)

    endpoint.makeRequest(urlRequest: urlRequest, handler: handler)
}
```
Very similar to the first method you defined, with only a few differences. Note that you are calling our endpoint with a extrac `checkId` parameter, and this time it is a GET call.

Now let's stitch and chain them together in our `Subscriber` protocol implementation.

```swift

public func check(phoneNumber: String, handler: @escaping (Result<SubscriberCheck, NetworkError>) -> Void) {

    self.createSubscriberCheck(phoneNumber: phoneNumber) { (createResult) in
        var checkURL = ""
        var checkID = ""

        switch createResult {
        case .success(let subscriberCheck):
            // The server returns the SubscriberCheck results to the device.
            checkURL = subscriberCheck.check_url!
            checkID = subscriberCheck.check_id!
            print("Got the subscriber check URL: \(String(describing: subscriberCheck.check_url)) ")
        case .failure(let error):
            handler(.failure(error))
            return
        }

        print("Using the SDK to request check URL over mobile network")
        self.requestSubscriberCheckURL(subscriberCheckURL: checkURL) { [weak self] in

            guard let self = self else {
                return
            }

            print("SDK successfully returned, let's call our server to retrieve check results.")
            self.retrieveSubscriberCheck(checkId: checkID) { (checkResult) in
                switch checkResult {
                case .success(let checkResultModel):
                    handler(.success(checkResultModel))
                case .failure(let error):
                    handler(.failure(error))
                }

            }
        }
    }

}
```

First, you are making a call using the `self.createSubscriberCheck(phoneNumber: phoneNumber) ...` method. The callback to this method, inspects the `Result<>`. It it is a success, fetches the `checkURL` and `checkID` and stores them in local variables which will be used later.

The second step is to use tru.ID iOS SDK to make call to SubscriberCheck URL. The SDK will make this call over the mobile network. The user must have data plan. Behind the scenes this call will redirect, and eventually return OK. All will be handled by the SDK.

The third steps is to make a final request the server using the check Id that you got as a result of making the first call. This call will return the Subscriber Check information; whether the check is successful or not.

You can find more on the **tru.ID** [subscriber check workflow integration](https://developer.tru.id/docs/subscriber-check/integration).

### Implement the User Action
At this point, you have our UI and you have necessary code to execute the SubscriberCheck workflow. This is where you put the final touches and get the View layer interact with the use case.

Let's first define a variable of `Subscriber` type in our `ViewController` and then implement the `next(_ sender: Any)` IBAction. Add the following code to your view controller.

```swift
var subscriberService: Subscriber!

override func viewDidLoad() {
    super.viewDidLoad()
    subscriberService = SubscriberCheckService()
}

```
you initialise our `subscriberService` with a concrete implementation `SubscriberCheckService` which you defined in the previous section. `SubscriberCheckService` knows how to execute the workflow and all `ViewController` needs to do is to call `check(phoneNumber: String, ..)` and control the UI state. It is time to implement the `next(_ sender: Any)`. It will look as follows:

```swift
@IBAction func next(_ sender: Any) {

    guard let phoneNumber = phoneNumberTextField.text else {
        return
    }

    if !phoneNumber.isEmpty {
        // Ideally you should validated phone number against e164 spec
        // Without leading + or 0's
        // For example: {country_code}{number}, 447940448591
        // Remove double 00's
        var strippedPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = strippedPhoneNumber.range(of: "00") {
            strippedPhoneNumber.replaceSubrange(range, with: "")
        }

        controls(enabled: false)

        subscriberService.check(phoneNumber: strippedPhoneNumber) { [weak self] (checkResult) in

            DispatchQueue.main.async {
                switch checkResult {
                case .success(let subscriberCheck):
                    self?.configureCheckResults(match: subscriberCheck.match ?? false, noSimChange: subscriberCheck.no_sim_change ?? false)
                case .failure(let error):
                    print("\(error)")
                }
                self?.controls(enabled:true)
            }

        }
    }

}

```
The implementation of the method first checks whether there is text in the `phoneNumberTextField` and if it is empty or not. Note that in a production code, you should validate that the phone number entered by the user obey the e164 specification. you are keeping it simple for the purposes of this tutorial, and only removing `00` from the begining of the phone number if exists.

The second step is to disable parts of the user interface, show the activity indicator and let it spin. The third step is to call the `check(phoneNumber:)` method of the `subscriberService`. The handler will provide a `checkResult` which is a type of `Result<SubscriberCheck,NetworkError>`.  Note that this closure will not be called in the main queue, therefore you need to wrap any code which accesses UIKit entities in a `DispatchQueue.main.async`.

If the workflow executes successfully then you access model details and reconfigure the UI. Not that the `.success` case doesn't necessarily mean that validation is successful, it is simply an indication that workflow executed without encountering any network errors.

In order to understand if you validated the phone number you need to inspect the `.success` payload which is of type `SubscriberCheck`. The following line will ensure that validation results are reflected on the UI:

```swift
self?.configureCheckResults(match: subscriberCheck.match ?? false, noSimChange: subscriberCheck.no_sim_change ?? false)
```

In any case, you restore the UI controls back to their original state so that the user can reexecute the workflow with the following code:

```swift
self?.controls(enabled:true)
```

### "Run Forest, Run!"
Now that our code is complete, you can run the application on a real device. Bear in mind that SIM card based authentication is not be possible on a Simulator as you require a SIM Card.

//Video

## Next
The completed sample app can be found in the **tru.ID** [sim-card-auth-ios][https://github.com/tru-ID/sim-card-auth-ios/] Github repository.

## Troubleshooting
### Mobile Data is Required

Don't forget that the SubcriberCheck validation requires your mobile device to have data plan from your network operator and you should enable mobile data.

### Get in touch

If you have any questions, get in touch via [help@tru.id](mailto:help@tru.id).

