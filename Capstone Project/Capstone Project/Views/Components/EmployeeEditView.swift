import SwiftUI

struct EmployeeEditView: View {
    let employee: Employee
    let repository: RemoteEmployeeDirectoryRepository
    let departments: [Department]
    let shifts: [ShiftOption]
    let onSaved: () async -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var employeeNumber = ""
    @State private var departmentId = 0
    @State private var shiftId = 0
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var hasEndDate = false
    @State private var firstName = ""
    @State private var lastName = ""

    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Employee") {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                
                LabeledContent(
                    "Employee ID",
                    value: "\(employee.employeeId)"
                )

                TextField("Employee Number", text: $employeeNumber)
                TextField("Title", text: $title)
            }

            Section("Department and Shift") {
                Picker("Department", selection: $departmentId) {
                    ForEach(departments) { department in
                        Text(department.name)
                            .tag(department.departmentId)
                    }
                }

                Picker("Shift", selection: $shiftId) {
                    ForEach(shifts) { shift in
                        Text(shift.name)
                            .tag(shift.shiftId)
                    }
                }
            }

            Section("Shift Dates") {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)

                Toggle("Has end date", isOn: $hasEndDate)

                if hasEndDate {
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        await saveEmployee()
                    }
                } label: {
                    if isSaving {
                        ProgressView("Saving...")
                    } else {
                        Text("Save Changes")
                    }
                }
                .disabled(
                    isSaving ||
                    employeeNumber.trimmingCharacters(
                        in: .whitespacesAndNewlines
                        
                    ).isEmpty ||
                    firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    departmentId == 0 ||
                    shiftId == 0 ||
                    (hasEndDate && endDate < startDate)
                    
                )
            }
        }
        .navigationTitle("Edit Employee")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel("Cancel")
                .disabled(isSaving)
            }
        }
        .onAppear {
            title = employee.title ?? ""
            employeeNumber = employee.employeeNumber ?? ""
            firstName = employee.firstName
            lastName = employee.lastName

            if let history = employee.shiftHistory?.first {
                departmentId = history.departmentId
                shiftId = history.shiftId
                startDate = history.startDate
                if let end = history.endDate {
                    endDate = end
                    hasEndDate = true
                } else {
                    hasEndDate = false
                }
            }
        }
    }

    private func saveEmployee() async {
        isSaving = true
        errorMessage = nil

        do {
            try await repository.updateEmployee(
                employeeId: employee.employeeId,
                firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                title: title.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                employeeNumber: employeeNumber.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ),
                departmentId: departmentId,
                shiftId: shiftId,
                startDate: startDate,
                endDate: hasEndDate ? endDate : nil            )

            await onSaved()
            dismiss()
        } catch {
            errorMessage =
                "Could not save employee changes: \(error.localizedDescription)"
        }

        isSaving = false
    }
}
