//
//  DataProvider.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation
import TruSDK

protocol Subscriber {
    func check(phoneNumber: String, withServer: String, handler: @escaping (Result<Int, NetworkError>)-> Void)
}

final class SubscriberCheck {
    
    /// Initiates the Subscriber Check workflow and calls the closure for success/failure
    /// - Parameters:
    ///   - url: url to the server
    ///   - handler: closure to execute either on success or failure scenarios
    func check(phoneNumber: String, withServer url: String, handler: @escaping (Result<Int, NetworkError>)-> Void) {

        // Workflow starts with:
        // Make a request to the application server (see initial set-up). This call can be made over any type of network (cellular/wifi). The application server should return SubscriberCheck URL.
        // Make a request to the SubscriberCheck URL, using the tru.ID iOS SDK. The SDK will make this call over the mobile network. The user must have data plan. This call will redirect, and return OK. This will be handled by the SDK. The SubscriberCheck request will return a result.
        // Use the results to make a fina call the application server again.
        // Show the results to the user

        let server = Server()
        server.retrieveSubscriberCheckURL(url: url) { (result) in

            let tru = TruSDK()
            tru.openCheckUrl(url: "") { (data) in

            }
        }

    }

}

extension SubscriberCheck: Subscriber {

}
