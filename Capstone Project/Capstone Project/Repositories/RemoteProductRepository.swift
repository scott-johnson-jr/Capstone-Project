//
//  ProductRepository.swift
//  Capstone Project
//
//  Created by user301577 on 11/16/26.
//
import Foundation

final class RemoteProductRepository: RepositoryProtocol {
    private let urlBase: String
    private let maxAge: TimeInterval = 15 * 60
    private var cachedProducts: [Product]?
    private var cacheTimestamp: Date?
    
    init(urlBase: String) {
        self.urlBase = urlBase
    }
    
    func getAll() async throws -> [Product] {
        if let products = cachedProducts,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) <= maxAge {
            return products
        }
        
        let data = try await fetchData("\(urlBase)/Product")
        let products = try decoder.decode([Product].self, from: data)
        cachedProducts = products
        cacheTimestamp = Date()
        return products
    }
    
    func getById(_ productId: Product.ID) async throws -> Product? {
        let data = try await fetchData("\(urlBase)/Product/\(productId)")
        return try decoder.decode(Product.self, from: data)
    }
    
    private func fetchData(_ urlString: String) async throws -> Data {
           guard let url = URL(string: urlString) else { throw URLError(.badURL) }
           let (data, response) = try await URLSession.shared.data(from: url)
           guard let http = response as? HTTPURLResponse,
                 (200..<300).contains(http.statusCode) else {
               throw URLError(.badServerResponse)
           }
           return data
       }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}
