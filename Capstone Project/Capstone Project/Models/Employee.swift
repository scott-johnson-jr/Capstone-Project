import Foundation

class Employee: Identifiable, Hashable, Codable {
    let employeeId: Int
    let employeeNumber: String?
    let firstName: String
    let middleName: String?
    let lastName: String
    let suffix: String?
    let title: String?
    let shift: String?
    let department: String?
    let hireDate: Date?
    let jobTitle: String
    let shiftHistory: [EmployeeShiftHistory]?

    var id: Int { employeeId }

    enum CodingKeys: String, CodingKey {
        case employeeId
        case employeeNumber
        case firstName
        case middleName
        case lastName
        case suffix
        case title
        case jobTitle
        case shiftHistory
        case shift
        case department
        case hireDate
    }

    init(
        employeeId: Int,
        firstName: String,
        lastName: String,
        title: String,
        shift: String,
        department: String,
        hireDate: Date,
        jobTitle: String
    ) {
        self.employeeId = employeeId
        self.employeeNumber = nil
        self.firstName = firstName
        self.middleName = nil
        self.lastName = lastName
        self.suffix = nil
        self.title = title
        self.shift = shift
        self.department = department
        self.hireDate = hireDate
        self.jobTitle = jobTitle
        self.shiftHistory = nil
    }

    static func == (lhs: Employee, rhs: Employee) -> Bool {
        lhs.employeeId == rhs.employeeId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(employeeId)
    }
}
