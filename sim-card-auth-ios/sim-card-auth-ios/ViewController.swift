//
//  ViewController.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 01/03/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var busyActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    let authProvider = SubscriberServicesProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func next(_ sender: Any) {

        //Without leading + or 0's
        //For example: {country_code}{number}, 447940448591
        guard let phoneNumber = phoneNumberTextField.text else {
            return
        }

        if !phoneNumber.isEmpty {
            //Ideally you should validated phone number against e164 spec
            controls(enabled:false)
            authProvider.validate(phoneNumber: phoneNumber) { [weak self] in

                self?.controls(enabled:true)
            }
        }

    }

    func controls(enabled: Bool) {
        enabled ? busyActivityIndicator.stopAnimating() : busyActivityIndicator.startAnimating()

        phoneNumberTextField.isEnabled = enabled
        nextButton.isEnabled = enabled
    }

}

