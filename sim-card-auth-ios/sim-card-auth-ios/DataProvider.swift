//
//  DataProvider.swift
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

struct Data: Codable {

}

class DataProvider {

    func retrieve(url: String, handler: @escaping (Result<Int, NetworkError>)-> Void) {

        guard let url = URL(string: url) else {
            handler(.failure(.invalidURL))
            return
        }

        let session = URLSession.shared

        let configuration = URLSessionConfiguration.ephemeral //We do not want OS to cache or persist
        configuration.allowsCellularAccess = true
        configuration.waitsForConnectivity = true
        configuration.networkServiceType = .responsiveData

        let urlRequest = URLRequest(url: url)

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

            guard let data = data, let mimeType = httpResponse.mimeType, mimeType == "text/html" else {
                handler(.failure(.noData))
                return
            }

            let string = String(data: data, encoding: .utf8)

            if let dataModel = try? JSONDecoder().decode(Data.self, from: data) {
                DispatchQueue.main.async {
                    handler(.success(0))
                }
                return
            }



            //            do {
            //                let json = try JSONSerialization.jsonObject(with: data, options: [])
            //                print(json)
            //            } catch {
            //                print("JSON error: \(error.localizedDescription)")
            //            }



        }

        task.resume()
    }
}
