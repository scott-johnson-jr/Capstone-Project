import Foundation

class RemoteEmployeeDirectoryRepository: RepositoryProtocol {
    private let urlBase: String

    init(urlBase: String) {
        self.urlBase = urlBase
    }

    func getAll() async throws -> [Employee] {
        let urlString = "\(urlBase)/Employee"
        let data = try await fetchData(urlString)
        return try decoder.decode([Employee].self, from: data)
    }

    func getById(_ employeeId: Employee.ID) async throws -> Employee? {
        let urlString = "\(urlBase)/Employee/\(employeeId)"
        let data = try await fetchData(urlString)
        return try decoder.decode(Employee.self, from: data)
    }

    func updateEmployee(
        employeeId: Int,
        title: String,
        employeeNumber: String,
        departmentId: Int,
        shiftId: Int,
        startDate: Date,
        endDate: Date
    ) async throws {
        let urlString = "\(urlBase)/Employee/\(employeeId)"

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
            "endDate": dateFormatter.string(from: endDate)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    private func fetchData(_ urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return data
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let fractionalFormatter = ISO8601DateFormatter()
            fractionalFormatter.formatOptions = [
                .withInternetDateTime,
                .withFractionalSeconds
            ]

            if let date = fractionalFormatter.date(from: dateString) {
                return date
            }

            let standardFormatter = ISO8601DateFormatter()
            standardFormatter.formatOptions = [.withInternetDateTime]

            if let date = standardFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateString)"
            )
        }

        return decoder
    }
}
