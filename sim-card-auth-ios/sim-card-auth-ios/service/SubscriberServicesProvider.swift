//
//  SimcardAuthProvider.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation

public class SubscriberServicesProvider {

    let subscriber: Subscriber

    init(dataProvider: Subscriber = SubscriberCheck()) {
        subscriber = dataProvider
    }

    /// Validates Simcard? ?????
    /// - Parameters:
    ///   - phoneNumber: e164 confirming phone number
    ///   - handler: callback for the validation results
    func validate(phoneNumber: String, handler: @escaping ()-> Void) {

        // This call will initiate the subscriber check workflow
        subscriber.check(phoneNumber: phoneNumber) { (result) in
            
            // The Server returns the SubscriberCheck results to the device.
            handler()
        }

    }
}
