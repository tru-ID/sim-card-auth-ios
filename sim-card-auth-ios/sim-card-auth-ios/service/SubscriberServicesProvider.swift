//
//  SimcardAuthProvider.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation

public class SubscriberServicesProvider {

    let provider: Subscriber
    let baseUrl: String

    init(dataProvider: Subscriber = SubscriberCheck()) {
        provider = dataProvider
        baseUrl = AppConfiguration().baseURL()!//Fail early so that we know there is somthing wrong
    }

    /// Validates Simcard? ?????
    /// - Parameters:
    ///   - phoneNumber: e164 confirming phone number
    ///   - handler: callback for the validation results
    func validate(phoneNumber: String, handler: @escaping ()->Void) {

        // This call will initiate the subscriber check workflow
        provider.check(phoneNumber: phoneNumber, withServer: "Server URL") { (result) in
            
            // The Server returns the SubscriberCheck results to the device.
        }

        handler()
    }
}
