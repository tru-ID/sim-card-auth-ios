//
//  SubscriberCheck.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation

enum SubcriberCheckStatus: String, Codable {
    case ACCEPTED
    case PENDING
    case COMPLETED
    case EXPIRED
    case ERROR
}

struct SubscriberCheckModel: Codable {
    let check_id: String
    let check_url: String
//    let status: SubcriberCheckStatus
//    let match: Bool
//    let no_sim_change: Bool
//    let charge_amount: Int
//    let charge_currency: String
//    let created_at: String
//    let snapshot_balance: Int
//    let _links: Links
}

struct Links: Codable {
    let `self`: [String : String]
    let check_url: [String : String]
}
