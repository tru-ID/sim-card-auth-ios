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
    
    @IBOutlet weak var checkResults: UIImageView!

    let subscriberService: Subscriber = SubscriberCheckService()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func next(_ sender: Any) {

        //Without leading + or 0's
        //For example: {country_code}{number}, 447940448591
        guard var phoneNumber = phoneNumberTextField.text else {
            return
        }

        if !phoneNumber.isEmpty {
            // Ideally you should validated phone number against e164 spec
            // Remove double 00's
            if let range = phoneNumber.range(of: "00") {
                phoneNumber.replaceSubrange(range, with: "")
            }

            controls(enabled:false)

            subscriberService.check(phoneNumber: phoneNumber) { [weak self] (checkResult) in

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

    // MARK: UI Controls Configure || Enable/Disable

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

}

