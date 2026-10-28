import Foundation

struct ShiftOption: Identifiable, Decodable, Hashable {
    let shiftId: Int
    let name: String
    let startTime: String
    let endTime: String

    var id: Int { shiftId }
}
