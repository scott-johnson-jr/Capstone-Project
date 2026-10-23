//
//  RemoteEmployeeDirectoryRepository.swift
//  Capstone Project
//

import Foundation
internal import CoreData

class RemoteEmployeeDirectoryRepository: RepositoryProtocol {

    private let urlBase: String
    private let context: NSManagedObjectContext

    private let memoryCache = NSCache<NSString, CacheBox>()
    private let cacheKey = "employees"
    private let maxAge: TimeInterval = 15 * 60

    private var cachedEmployees: [Employee]?
    private var cacheTimestamp: Date?

    init(
        urlBase: String,
        context: NSManagedObjectContext =
            PersistenceController.shared.container.viewContext
    ) {
        self.urlBase = urlBase
        self.context = context
    }

    func getAll() async throws -> [Employee] {
        // 1. Check the in-memory cache.
        if let employees = cachedEmployees,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) <= maxAge {
            return employees
        }

        // 2. Try the API.
        do {
            let data = try await fetchData("\(urlBase)/Employee")
            let employees = try decoder.decode([Employee].self, from: data)

            // Save the fresh response to Core Data.
            try await saveEmployees(employees)

            // Update the in-memory cache.
            cachedEmployees = employees
            cacheTimestamp = Date()

            return employees
        } catch {
            // 3. Fall back to saved employees.
            let savedEmployees = try await fetchCachedEmployees()

            if !savedEmployees.isEmpty {
                cachedEmployees = savedEmployees
                cacheTimestamp = Date()
                return savedEmployees
            }

            // Nothing is cached, so report the original API error.
            throw error
        }
    }

    func getById(_ employeeId: Employee.ID) async throws -> Employee? {
        let employees = try await getAll()
        return employees.first { $0.employeeId == employeeId }
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

    private func saveEmployees(_ employees: [Employee]) async throws {
        try await context.perform {
            for employee in employees {
                let request = EmployeeEntity.fetchRequest()
                request.predicate = NSPredicate(
                    format: "employeeId == %@",
                    NSNumber(value: employee.employeeId)
                )

                let entity = try self.context.fetch(request).first
                    ?? EmployeeEntity(context: self.context)

                entity.employeeId = Int64(employee.employeeId)
                entity.firstName = employee.firstName
                entity.lastName = employee.lastName
                entity.title = employee.title
                entity.shift = employee.shift
                entity.department = employee.department
                entity.hireDate = employee.hireDate
                entity.jobTitle = employee.jobTitle
                entity.lastUpdated = Date()
            }

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    private func fetchCachedEmployees() async throws -> [Employee] {
        try await context.perform {
            let request = EmployeeEntity.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "lastName", ascending: true),
                NSSortDescriptor(key: "firstName", ascending: true)
            ]

            return try self.context.fetch(request).compactMap { entity in
                guard let firstName = entity.firstName,
                      let lastName = entity.lastName,
                      let jobTitle = entity.jobTitle else {
                    return nil
                }

                return Employee(
                    employeeId: Int(entity.employeeId),
                    firstName: firstName,
                    lastName: lastName,
                    title: entity.title ?? "",
                    shift: entity.shift ?? "",
                    department: entity.department ?? "",
                    hireDate: entity.hireDate ?? Date(),
                    jobTitle: jobTitle
                )
            }
        }
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
