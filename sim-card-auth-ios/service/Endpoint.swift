//
//  Server.swift
//  sim-card-auth-ios
//
//  Created by Murat Yakici on 06/03/2021.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case connectionFailed(String)
    case httpNotOK
    case noData
}

final class Endpoint<T: Decodable> {

    let baseURL: String
    let session: URLSession

    init(withBaseURL url: String) {
        baseURL = url
        session = Endpoint.createSession()
    }

    func makeRequest(urlRequest: URLRequest,
                     handler: @escaping (Result<T, NetworkError>) -> Void) {
        
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

            print("Reponse: \(String(describing: String(data: data, encoding: .utf8)))")

            if let dataModel = try? JSONDecoder().decode(T.self, from: data) {
                    handler(.success(dataModel))
                return
            }
        }

        task.resume()
    }

    private static func createSession() -> URLSession {

        let configuration = URLSessionConfiguration.ephemeral //We do not want OS to cache or persist
        configuration.allowsCellularAccess = true
        configuration.waitsForConnectivity = true
        configuration.networkServiceType = .responsiveData

        return URLSession(configuration: configuration)
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

