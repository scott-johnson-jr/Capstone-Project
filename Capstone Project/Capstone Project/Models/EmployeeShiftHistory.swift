import Foundation

struct EmployeeShiftHistory: Codable, Hashable {
    let employeeId: Int
    let departmentId: Int
    let departmentName: String
    let departmentGroup: String
    let shiftId: Int
    let shiftName: String
    let startDate: Date
    let endDate: Date?
}
