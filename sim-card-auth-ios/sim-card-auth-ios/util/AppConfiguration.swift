//
//  AppConfiguration.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

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
        key = "staging_server_base_url"
        #endif
        return configuration?[key] as? String
    }

}
