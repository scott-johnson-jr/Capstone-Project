//
//  RemoteProductRepository.swift
//  Capstone Project
//
//  Created by user301577 on 10/12/26.
//

import Foundation
// remote repository for the images in the orderdetails app
class RemoteOrderProductRepository: RepositoryProtocol {

    private let urlBase: String

    init(urlBase: String) {
        self.urlBase = urlBase
    }

    func getAll() async throws -> [OrderProduct] {
        let urlString = "\(urlBase)/Product"
        return try await fetchAll(urlString)
    }

    func getById(_ orderProductId: OrderProduct.ID) async throws -> OrderProduct? {
        let urlString = "\(urlBase)/Product"
        return try await fetchOne(urlString)
    }


    private func fetchAll(_ urlString: String) async throws -> [OrderProduct] {
        let data = try await fetchData(urlString)
        return try JSONDecoder().decode([OrderProduct].self, from: data)
    }

    private func fetchOne(_ urlString: String) async throws -> OrderProduct? {
        let data = try await fetchData(urlString)
        return try JSONDecoder().decode(OrderProduct.self, from: data)
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
    
}
