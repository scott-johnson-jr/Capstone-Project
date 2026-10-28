import Foundation

struct Department: Identifiable, Decodable, Hashable {
    let departmentId: Int
    let name: String
    let groupName: String

    var id: Int { departmentId }
}
