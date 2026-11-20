import Foundation
internal import CoreData

class RemoteEmployeeDirectoryRepository: RepositoryProtocol {
    private let urlBase: String
    private let context: NSManagedObjectContext

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
        if let employees = cachedEmployees,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) <= maxAge {
            return employees
        }

        do {
            let data = try await fetchData("\(urlBase)/Employee")
            let employees = try decoder.decode([Employee].self, from: data)

            try await saveEmployees(employees)

            cachedEmployees = employees
            cacheTimestamp = Date()

            return employees
        } catch {
            let saved = try await fetchCachedEmployees()

            if !saved.isEmpty {
                cachedEmployees = saved
                cacheTimestamp = Date()
                return saved
            }

            throw error
        }
    }

    func getById(_ employeeId: Employee.ID) async throws -> Employee? {
        do {
            let data = try await fetchData(
                "\(urlBase)/Employee/\(employeeId)"
            )

            return try decoder.decode(Employee.self, from: data)
        } catch {
            let saved = try await fetchCachedEmployees()

            if let employee = saved.first(where: {
                $0.employeeId == employeeId
            }) {
                return employee
            }

            throw error
        }
    }

    private func fetchData(_ urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

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

    func updateEmployee(
        employeeId: Int,
        firstName: String,
        lastName: String,
        title: String,
        employeeNumber: String,
        departmentId: Int,
        shiftId: Int,
        startDate: Date,
        endDate: Date?
    ) async throws {
        let urlString = "\(urlBase)/Employee/employment/\(employeeId)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        
        let body: [String: Any] = [
            "title": title,
            "employeeNumber": employeeNumber,
            "departmentId": departmentId,
            "shiftId": shiftId,
            "startDate": dateFormatter.string(from: startDate),
            "endDate": endDate.map {
                dateFormatter.string(from: $0)
            } ?? NSNull()
        ]


        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = try JSONSerialization.data(
            withJSONObject: body
        )
        
        
        if let requestBody = String(
            data: request.httpBody ?? Data(),
            encoding: .utf8
        ) {
            print("Employment request body: \(requestBody)")
        }

        print("Employment request URL: \(urlString)")


        
        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("Employment update status: \(httpResponse.statusCode)")

        if let responseBody = String(data: data, encoding: .utf8) {
            print("Employment update response: \(responseBody)")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }


        cachedEmployees = nil
        cacheTimestamp = nil
    }
    
    
    func updateEmployeePersonal(
        employeeId: Int,
        firstName: String,
        middleName: String,
        lastName: String,
        suffix: String
    ) async throws {
        let urlString = "\(urlBase)/Employee/personal/\(employeeId)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let body: [String: Any] = [
            "firstName": firstName,
            "middleName": middleName,
            "lastName": lastName,
            "suffix": suffix
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        cachedEmployees = nil
        cacheTimestamp = nil
    }


    private static let zonedFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()

    private static let zoned: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let noZoneFormatters: [DateFormatter] =
        [
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss"
        ].map { format in
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            return formatter
        }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            if let date = Self.zonedFractional.date(from: string) {
                return date
            }

            if let date = Self.zoned.date(from: string) {
                return date
            }

            for formatter in Self.noZoneFormatters {
                if let date = formatter.date(from: string) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(string)"
            )
        }

        return decoder
    }
}
