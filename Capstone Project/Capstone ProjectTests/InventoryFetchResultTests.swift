
import Testing
@testable import Capstone_Project

struct InventoryFetchResultTests {

    @Test func cachedResultIsIdentified() {
        let result = InventoryFetchResult(
            items: [],
            isFromCache: true
        )

        #expect(result.isFromCache == true)
        #expect(result.items.isEmpty)
    }

    @Test func freshResultIsIdentified() {
        let result = InventoryFetchResult(
            items: [],
            isFromCache: false
        )

        #expect(result.isFromCache == false)
    }
}

