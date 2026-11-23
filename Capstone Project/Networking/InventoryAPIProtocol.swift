
import Foundation

protocol InventoryAPIProtocol {
    func get<T: Decodable>(
        _ endpoint: String,
        responseType: T.Type
    ) async throws -> T
}

extension APIClient: InventoryAPIProtocol {}

