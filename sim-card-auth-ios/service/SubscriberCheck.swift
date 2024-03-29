//
//  SubscriberCheck.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation

// Response model based on https://developer.tru.id/docs/reference/api#operation/create-subscriber-check
struct SubscriberCheck: Codable {
    let check_id: String?
    let check_url: String?
    let status: SubscriberCheckStatus?
    let match: Bool?
    let no_sim_change: Bool?
}

enum SubscriberCheckStatus: String, Codable {
    case ACCEPTED
    case PENDING
    case COMPLETED
    case EXPIRED
    case ERROR
}

enum NetworkError: Error {
    case invalidURL
    case connectionFailed(String)
    case httpNotOK
    case noData
}
