
import Foundation
import Observation

@MainActor
@Observable
final class CatalogViewModel {

    enum State {
        case loading
        case loaded([Product])
        case failed(String)
    }

    private(set) var state: State = .loading
    private(set) var isRefreshing = false
    private(set) var errorMessage: String?

    func load(using repository: any RepositoryProtocol<Product>) async {
        guard !isRefreshing else { return }

        let existingProducts: [Product]?

        if case .loaded(let products) = state {
            existingProducts = products
        } else {
            existingProducts = nil
        }

        isRefreshing = true
        errorMessage = nil

        if existingProducts == nil {
            state = .loading
        }

        defer {
            isRefreshing = false
        }

        do {
            let products = try await repository.getAll()
            state = .loaded(products)
            errorMessage = nil
        } catch {
            if let existingProducts {
                state = .loaded(existingProducts)
                errorMessage = "Unable to refresh products. Showing previously loaded products. Please try again."
            } else {
                state = .failed(
                    "Unable to load products. Please check your connection and try again."
                )
            }
        }
    }
}

