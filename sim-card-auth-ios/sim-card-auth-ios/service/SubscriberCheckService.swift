//
//  DataProvider.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation
import TruSDK

/**
 This class helps accomplish Subscriber Check.

 # For a detailed integration of [subscriber check workflow](https://developer.tru.id/docs/subscriber-check/integration). Here are the steps:
 - Make a POST request to the application server (see initial set-up in README.md). This call can be made over any type of network (cellular/wifi). The application server should return SubscriberCheck URL.
 - Use tru.ID iOS SDK to make call to SubscriberCheck URL. The SDK will make this call over the mobile network. The user must have data plan. This call will redirect, and eventually return OK. This will be handled by the SDK.
 - Up on success, make a final request the application server using the check Id. This call will return the Subscriber Check information.
 */
protocol Subscriber {
    func check(phoneNumber: String, handler: @escaping (Result<SubscriberCheck, NetworkError>)-> Void)
}

final class SubscriberCheckService {

    //?? API documentation and Node.js endpoints and call conventions are slightly different
    // Node.js forwards to https://eu.api.tru.id/subscriber_check/v0.1/checks
    // Response is strip down as well.
    let endpoint = "/subscriber-check"
    let baseUrl: String
    let server: Server<SubscriberCheck>
    
    init() {
        var configuration = AppConfiguration()
        configuration.loadServerConfiguration()
        baseUrl = configuration.baseURL()!//Fail early so that we know there is something wrong
        server = Server<SubscriberCheck>(withBaseURL: baseUrl)
    }

    /// Initiates the Subscriber Check workflow and calls the closure for success/failure
    /// - Parameters:
    ///   - phoneNumber: e164 confirming phone number
    ///   - handler: closure to execute either on success or failure scenarios for the validation results
    func check(phoneNumber: String, handler: @escaping (Result<SubscriberCheck, NetworkError>)-> Void) {

        server.createSubscriberCheck(withPhoneNumber: phoneNumber, path: endpoint) { (result) in

            var checkURL = ""
            var checkID = ""

            switch result {
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
                self.server.retrieveSubscriberCheck(checkId: checkID, path: self.endpoint) { (result) in
                    switch result {
                    case .success(let checkResult):
                        handler(.success(checkResult))
                    case .failure(let error):
                        handler(.failure(error))
                    }

                }
            }

        }

    }

    private func requestSubscriberCheckURL(subscriberCheckURL: String, handler: @escaping ()-> Void) {

        let tru = TruSDK()

        tru.openCheckUrl(url: subscriberCheckURL) { (something) in
            //Are we assuming success here?SDK doesn't tell us what the call means?
            handler()

        }
    }

}

extension SubscriberCheckService: Subscriber {

}
