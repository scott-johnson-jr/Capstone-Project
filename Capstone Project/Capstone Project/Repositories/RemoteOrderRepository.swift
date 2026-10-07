//
//  RemoteOrderRepository.swift
//  Capstone Project
//
//  Created by user301577 on 10/6/26.
//


import Foundation

class RemoteOrderRepositoryDirectory: RepositoryProtocol {

    private let urlBase: String

    init(urlBase: String) {
        self.urlBase = urlBase
    }

    func getAll() async throws -> [Order] {
        let urlString = "\(urlBase)/Order/Customer/"
        return try await fetchAll(urlString)
    }

    func getById(_ orderId: Order.ID) async throws -> Order? {
        let urlString = "\(urlBase)/Order/Customer/\(orderId)"
        return try await fetchOne(urlString)
    }


    private func fetchAll(_ urlString: String) async throws -> [Order] {
        let data = try await fetchData(urlString)
        return try decoder.decode([Order].self, from: data)
    }

    private func fetchOne(_ urlString: String) async throws -> Order? {
        let data = try await fetchData(urlString)
        return try decoder.decode(Order.self, from: data)
    }

    private func fetchData(_ urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
                
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    private var decoder: JSONDecoder {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
    
}
