
import Testing
@testable import Capstone_Project

struct Capstone_ProjectTests {

    @Test func inventoryFetchResultIdentifiesCachedData() {
        let result = InventoryFetchResult(
            items: [],
            isFromCache: true
        )

        #expect(result.isFromCache == true)
        #expect(result.items.isEmpty)
    }

    @Test func inventoryFetchResultIdentifiesFreshData() {
        let result = InventoryFetchResult(
            items: [],
            isFromCache: false
        )

        #expect(result.isFromCache == false)
    }
}

