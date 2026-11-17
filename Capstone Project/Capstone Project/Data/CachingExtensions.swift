//
//  CachingExtensions.swift
//  Capstone Project
//
//  Created by user301577 on 10/21/26.
//

enum CachingConfigurationError: Error {
    case missingManagedObjectContext
}


enum DecoderConfigurationError: Error {
    case missingManagedObjectContext
    
    
}

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
