//
//  SessionEndpoint.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    func makeRequest<U: Decodable>(urlRequest: URLRequest,
                     handler: @escaping (Result<U, NetworkError>) -> Void)
    
    func createURLRequest(method: String,
                          url: URL,
                          payload:[String : String]?) -> URLRequest
}

final class SessionEndpoint: Endpoint {

    let baseURL: String
    private let session: URLSession

    init() {
        var configuration = AppConfiguration()
        configuration.loadServerConfiguration()
        baseURL = configuration.baseURL()!//Fail early so that we know there is something wrong
        session = SessionEndpoint.createSession()
    }

    private static func createSession() -> URLSession {

        let configuration = URLSessionConfiguration.ephemeral //We do not want OS to cache or persist
        configuration.allowsCellularAccess = true
        configuration.waitsForConnectivity = true
        configuration.networkServiceType = .responsiveData

        return URLSession(configuration: configuration)
    }
    
    // MARK: Protocol Implementation
    func makeRequest<U: Decodable>(urlRequest: URLRequest,
                     handler: @escaping (Result<U, NetworkError>) -> Void) {
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in

            if let error = error {
                handler(.failure(.connectionFailed(error.localizedDescription)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                handler(.failure(.connectionFailed("HTTP not OK")))
                return
            }

            guard let data = data else {
                handler(.failure(.noData))
                return
            }

            print("Response: \(String(describing: String(data: data, encoding: .utf8)))")

            if let dataModel = try? JSONDecoder().decode(U.self, from: data) {
                    handler(.success(dataModel))
                return
            }
        }

        task.resume()
    }

    func createURLRequest(method: String, url: URL, payload:[String : String]?) -> URLRequest {

        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = method

        if let payload = payload {
            let jsonData = try! JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            urlRequest.httpBody = jsonData
        }

        return urlRequest
    }
}

