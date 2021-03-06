//
//  DataProvider.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation

protocol Subscriber {
    func check(withServer: String, handler: @escaping (Result<Int, NetworkError>)-> Void)
}

final class SubscriberCheck {

    /// Initiates the Subscriber Check workflow and calls the closure for success/failure
    /// - Parameters:
    ///   - url: url to the server
    ///   - handler: closure to execute either on success or failure scenarios
    func check(withServer url: String, handler: @escaping (Result<Int, NetworkError>)-> Void) {

        // Workflow starts with making a request to the server (see initial set-up). This call can be made on any type of network (cellular/wifi).
        // And server should return SubscriberCheck URL
        // Then using the SDK, and over the mobile network
        //      make a request to the SubscriberCheck URL
        //      this will redirect, and return OK. This is handled by the sdk
        // The using that SubscriberCheck URL result, call the Server

        let server = Server()
        server.retrieveSubscriberCheckURL(url: url) { (result) in
            
        }

    }
}

extension SubscriberCheck: Subscriber {

}
