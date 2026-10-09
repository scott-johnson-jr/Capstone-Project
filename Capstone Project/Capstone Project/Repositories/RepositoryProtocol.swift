//
//  RepositoryProtocol.swift
//  Capstone Project
//
//  Created by user301577 on 9/29/26.
//

protocol RepositoryProtocol<Item> {
    
    associatedtype Item: Identifiable, Codable
    
    func getAll() async throws -> [Item]
    func getById(_ id: Item.ID) async throws -> Item?

    
    
}
