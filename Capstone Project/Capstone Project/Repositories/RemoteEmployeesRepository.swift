//
//  RemoteEmployeesRepository.swift
//  Capstone Project
//
//  Created by user301577 on 9/25/26.
//

import Foundation

class RemoteEmployeeDirectoryRepository: RepositoryProtocol {

    private let urlBase: String

    init(urlBase: String) {
        self.urlBase = urlBase
    }

    func getAll() async throws -> [Employee] {
        let urlString = "\(urlBase)/Employee"
        return try await fetchAll(urlString)
    }

    func getById(_ employeeId: Employee.ID) async throws -> Employee? {
        let urlString = "\(urlBase)/Employee/\(employeeId)"
        return try await fetchOne(urlString)
    }


    private func fetchAll(_ urlString: String) async throws -> [Employee] {
        let data = try await fetchData(urlString)
        return try decoder.decode([Employee].self, from: data)
    }

    private func fetchOne(_ urlString: String) async throws -> Employee? {
        let data = try await fetchData(urlString)
        return try decoder.decode(Employee.self, from: data)
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
