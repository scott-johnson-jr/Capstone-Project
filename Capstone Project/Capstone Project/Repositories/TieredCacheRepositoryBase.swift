//
//  TieredCacheRepositoryBase.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//

import Foundation
internal import CoreData

class TieredCachedRepositoryBase<Item: Codable & Identifiable & NSManagedObject>:
    RemoteRepositoryBase<Item>,
    TieredCachedRepositoryProtocol<Item> {
    
    private let memoryCache = NSCache<NSString, CacheBox>()
    private let cacheKeyPrefix = String(describing: Item.self)
    private let maxAge: TimeInterval = 15 * 60.0
    
    private let urlBase: String
    private let context: NSManagedObjectContext?
    
    private override init(authStatus: AuthStatus) {
            self.urlBase = ""
            self.context = nil
            super.init(authStatus: authStatus)
        }
        
    
    
    init(authStatus: AuthStatus, urlBase: String, context: NSManagedObjectContext) {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 20 * 1024 * 1024
        
        
        self.urlBase = urlBase
        self.context = context
        
        super.init(authStatus: authStatus)
        super.implicitContext = context

        
    }
    
    
    func getAll() async throws -> ([Item], CachedDataSource) {
        
        let now = Date()
        
        if let box = memoryCache.object(forKey: urlBase as NSString) {
            let age = now.timeIntervalSince(box.timestamp)
            let decoder = JSONDecoder()
            decoder.userInfo[CodingUserInfoKey.managedObjectContext] = self.context
            if age <= maxAge,
               let decoded = try? JSONDecoder().decode([Item].self, from: box.payload) {
                return (decoded, .memory)
            }
        }
        
        
        
        
        guard let context = context else {
            throw CachingConfigurationError.missingManagedObjectContext
        }
        let results = try await context.perform {
            let request = NSFetchRequest<Item>(entityName: String(describing: Item.self))
            request.fetchLimit = 10
            return try context.fetch(request)
        }
        if !results.isEmpty {

            let payload = try JSONEncoder().encode(results)
            let box = CacheBox(payload: payload, timestamp: now)
            memoryCache.setObject(box, forKey: urlBase as NSString)
            
            return (results, .disk)
        }
        
        
        let apiResults = try await fetchAll(urlBase)
        apiResults.forEach { result in
            context.insert(result)
        }
        try context.save()
        
        return (apiResults, .notcached)
        
        
    }
        
    }
