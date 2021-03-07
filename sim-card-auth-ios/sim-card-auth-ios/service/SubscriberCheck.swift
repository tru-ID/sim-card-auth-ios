//
//  DataProvider.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation
import TruSDK

/**
 This class helps accomplish Subscriber check.

 # Workflow:
 - Make a request to the application server (see initial set-up). This call can be made over any type of network (cellular/wifi). The application server should return Subscriber Check URL.
 - Make a request to the SubscriberCheckURL, using the tru.ID iOS SDK. The SDK will make this call over the mobile network. The user must have data plan. This call will redirect, and return OK. This will be handled by the SDK. The SubscriberCheck request will return a result.
 - Use the results to make a fina call the application server again.
 - Show the results to the user
 */
protocol Subscriber {
    func check(phoneNumber: String, handler: @escaping (Result<Int, NetworkError>)-> Void)
}

final class SubscriberCheck {

    let endpoint = "/subscriber-check"
    //?? API documentation and Node.js is different
    // Node.js forwards to https://eu.api.tru.id/subscriber_check/v0.1/checks
    // Response is strip down as well.
    let baseUrl: String
    let server: Server<SubscriberCheckModel>
    
    init() {
        var configuration = AppConfiguration()
        configuration.loadServerConfiguration()
        baseUrl = configuration.baseURL()!//Fail early so that we know there is somthing wrong
        server = Server<SubscriberCheckModel>(withBaseURL: baseUrl)
    }

    /// Initiates the Subscriber Check workflow and calls the closure for success/failure
    /// - Parameters:
    ///   - url: url to the server
    ///   - handler: closure to execute either on success or failure scenarios
    func check(phoneNumber: String, handler: @escaping (Result<Int, NetworkError>)-> Void) {

        server.createSubscriberCheck(withPhoneNumber: phoneNumber, path: endpoint) { (result) in

            let subscriberCheckURL: String = ""

            let tru = TruSDK()
            tru.openCheckUrl(url: subscriberCheckURL) { [weak self] (data) in

                guard let path = self?.endpoint else {
                    handler(.failure(.connectionFailed("SDK call was not successful.")))
                    return
                }

                self?.server.retrieveSubscriberCheck(checkId: "", path: path) { (checkResult) in
                    handler(.success(0))
                }

            }
        }

    }

}

extension SubscriberCheck: Subscriber {

}
