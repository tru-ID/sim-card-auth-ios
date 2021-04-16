//
//  SubscriberCheckService.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation
import TruSDK

/**
 This class implements the SubscriberCheck workflow.

 # For a detailed integration of [subscriber check workflow](https://developer.tru.id/docs/subscriber-check/integration). Here are the steps:
 - Make a POST request to the application server (see initial set-up in README.md). This call can be made over any type of network (cellular/wifi). The application server should return SubscriberCheck URL.
 - Use tru.ID iOS SDK to make call to SubscriberCheck URL. The SDK will make this call over the mobile network. The user must have data plan. This call will redirect, and eventually return OK. This will be handled by the SDK.
 - Up on success, make a final request the application server using the check Id. This call will return the Subscriber Check information.
 */
protocol Subscriber {
    func check(phoneNumber: String,
               handler: @escaping (Result<SubscriberCheck, NetworkError>) -> Void)
}

final class SubscriberCheckService: Subscriber {

    // Note that **tru.ID** CLI Node.js development server API and call conventions are slightly different.
    // i.e Response is strip down.
    // Your production server may have a different endpoint, and response model.
    // Note that the development server will forwards requests to https://eu.api.tru.id/subscriber_check/v0.1/checks
    let path = "/subscriber-check"
    let endpoint: Endpoint
        
    init(){
        self.endpoint = SessionEndpoint()
    }

    // MARK: Subscriber protocol
    
    /// Initiates the SubscriberCheck workflow and calls the closure for success/failure
    /// - Parameters:
    ///   - phoneNumber: e164 confirming phone number
    ///   - handler: closure to execute either on success or failure scenarios for the validation results
    public func check(phoneNumber: String, handler: @escaping (Result<SubscriberCheck, NetworkError>) -> Void) {

        createSubscriberCheck(phoneNumber: phoneNumber) { (createResult) in
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
    
    /// Retrieves the results of a SubscriberCheck given a check Id
    /// - Parameters:
    ///   - checkId: Check id receives when you created the SubscriberCheck `createSubscriberCheck`
    ///   - handler: callback
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

    
    /// This method uses the **tru.ID** SDK to initiate call over the cellular network.
    /// - Parameters:
    ///   - subscriberCheckURL: URL that you received from **your** (development/production) server
    ///   - handler: callback on the results of the call
    private func requestSubscriberCheckURL(subscriberCheckURL: String,
                                           handler: @escaping () -> Void) {

        let tru = TruSDK()

        tru.openCheckUrl(url: subscriberCheckURL) { (something) in
            handler()
        }
    }

}
