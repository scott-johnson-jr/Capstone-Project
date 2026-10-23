//
//  TieredCacheRepositoryProtocol.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//

enum CachedDataSource {
    case memory
    case disk
    case notcached
}

protocol TieredCachedRepositoryProtocol<Item> {
    
    associatedtype Item: Identifiable, Codable
    
    func getAll() async throws -> ([Item], CachedDataSource)
    
    
}
