import SwiftUI

struct EmployeeList: View {
    @Environment(\.employeeRepository) var employeeRepository
    @State var viewModel: ViewModel

    private let repository: any RepositoryProtocol<Employee>

    @State private var editingEmployee: Employee?
    @State private var departments: [Department] = []
    @State private var shifts: [ShiftOption] = []
    @State private var isPreparingEdit = false
    @State private var editLoadError: String?

    init(repository: any RepositoryProtocol<Employee>) {
        self.repository = repository
        _viewModel = State(
            wrappedValue: ViewModel(repository: repository)
        )
    }

    var body: some View {
        VStack {
            BannerError(model: viewModel)

            VStack(spacing: 6) {
                Text("Employee Directory")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)

                HStack {
                    Text("Filter")
                    TextField("Name/Dept/ID", text: $viewModel.filter)

                    Menu {
                        Picker("Sort by", selection: $viewModel.sortOption) {
                            ForEach(ViewModel.SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .accessibilityLabel("Sort employees")
                    }
                }
                .fixedSize(horizontal: true, vertical: false)
                .padding()

                HStack {
                    Text("Name")
                    Spacer(minLength: 16)
                    Text("Department")
                }
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)
            .padding(.bottom, 4)

            List(viewModel.sortedEmployees) { employee in
                let isSelected = viewModel.selectedEmployee?.id == employee.id

                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 4) {
                        if let title = employee.title, !title.isEmpty {
                            Text(title)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Text("\(employee.firstName) \(employee.lastName)")
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    if let department = employee.department, !department.isEmpty {
                        Text(department)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 8)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        viewModel.selectedEmployee = employee
                    }
                }
                .listRowBackground(rowBackground(for: employee))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    "\(employee.firstName) \(employee.lastName), Department: \(employee.department ?? "None")"
                )
                .accessibilityValue(isSelected ? "Selected" : "")
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("Double tap to view employee details")
            }
            .frame(maxWidth: .infinity)

            Divider()

            detailPanel
                .frame(maxWidth: .infinity)
        }
        .task {
            await viewModel.loadEmployees()
        }
        .sheet(item: $editingEmployee) { employee in
            if let remoteRepository = repository as? RemoteEmployeeDirectoryRepository {
                NavigationStack {
                    EmployeeEditView(
                        employee: employee,
                        repository: remoteRepository,
                        departments: departments,
                        shifts: shifts,
                        onSaved: {
                            await viewModel.loadEmployees()
                        }
                    )
                }
            }
        }
        .alert(
            "Employee Update",
            isPresented: Binding(
                get: { editLoadError != nil },
                set: { if !$0 { editLoadError = nil } }
            )
        ) {
            Button("OK", role: .cancel) {
                editLoadError = nil
            }
        } message: {
            Text(editLoadError ?? "")
        }
    }

    private func rowBackground(for employee: Employee) -> Color {
        if viewModel.selectedEmployee?.id == employee.id {
            Color.gray.opacity(0.25)
        } else {
            Color(.secondarySystemGroupedBackground)
        }
    }

    @ViewBuilder
    private var detailPanel: some View {
        if let employee = viewModel.selectedEmployee {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)

                VStack(spacing: 0) {
                    detailRow(title: "Employee ID", value: "\(employee.employeeId)")
                    Divider()
                    detailRow(title: "Job Title", value: employee.jobTitle)
                    Divider()
                    detailRow(title: "Shift", value: employee.shift ?? "None")
                    Divider()
                    detailRow(
                        title: "Hire Date",
                        value: employee.hireDate?.formatted(
                            date: .abbreviated,
                            time: .omitted
                        ) ?? "N/A"
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .background(.background, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.top, 8)

                Button {
                    Task {
                        await prepareEmployeeEdit(employee)
                    }
                } label: {
                    if isPreparingEdit {
                        ProgressView("Loading employee...")
                    } else {
                        Label("Edit Employee", systemImage: "pencil")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isPreparingEdit)
                .padding(.vertical, 12)
            }
            .transition(.move(edge: .bottom))
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title).font(.subheadline.bold())
            Text(" - ")
            Spacer(minLength: 16)
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }

    private func prepareEmployeeEdit(_ employee: Employee) async {
        guard let remoteRepository = repository as? RemoteEmployeeDirectoryRepository else {
            editLoadError = "The employee repository does not support updates."
            return
        }

        isPreparingEdit = true
        defer { isPreparingEdit = false }

        do {
            guard let fullEmployee = try await remoteRepository.getById(employee.employeeId) else {
                editLoadError = "Employee details could not be found."
                return
            }

            let apiClient = APIClient()
            let loadedDepartments = try await apiClient.fetchDepartments()
            let loadedShifts = try await apiClient.fetchShiftOptions()

            departments = loadedDepartments
            shifts = loadedShifts
            editingEmployee = fullEmployee
        } catch {
            editLoadError = "Could not load employee details: \(error.localizedDescription)"
        }
    }
}

extension EmployeeList {
    @Observable
    class ViewModel: Failable {
        enum SortOption: String, CaseIterable {
            case name = "Name"
            case department = "Department"
            case employeeID = "Employee ID"
        }

        var sortOption: SortOption = .department
        private let repository: any RepositoryProtocol<Employee>

        init(repository: any RepositoryProtocol<Employee>) {
            self.repository = repository
        }

        var errorMessage: String = ""

        var employees: [Employee] = [] {
            didSet {
                selectedEmployee = nil
                updateMatchingEmployees()
            }
        }

        var filter: String = "" {
            didSet {
                updateMatchingEmployees()
            }
        }

        var matchingEmployees: [Employee] = [] {
            didSet {
                if let selected = selectedEmployee,
                   !matchingEmployees.contains(selected) {
                    selectedEmployee = nil
                }
            }
        }

        private func updateMatchingEmployees() {
            matchingEmployees = employees.filter { employee in
                filter.isEmpty ||
                "\(employee.firstName) \(employee.lastName)"
                    .localizedCaseInsensitiveContains(filter) ||
                (employee.department ?? "")
                    .localizedCaseInsensitiveContains(filter) ||
                String(employee.employeeId).contains(filter)
            }
        }

        var sortedEmployees: [Employee] {
            matchingEmployees.sorted { first, second in
                switch sortOption {
                case .name:
                    let firstName = "\(first.firstName) \(first.lastName)"
                    let secondName = "\(second.firstName) \(second.lastName)"
                    let comparison = firstName.localizedCaseInsensitiveCompare(secondName)
                    if comparison == .orderedSame {
                        return first.employeeId < second.employeeId
                    }
                    return comparison == .orderedAscending

                case .department:
                    let firstDepartment = first.department ?? ""
                    let secondDepartment = second.department ?? ""
                    let comparison = firstDepartment.localizedCaseInsensitiveCompare(secondDepartment)
                    if comparison == .orderedSame {
                        return first.employeeId < second.employeeId
                    }
                    return comparison == .orderedAscending

                case .employeeID:
                    return first.employeeId < second.employeeId
                }
            }
        }

        var selectedEmployee: Employee?

        func loadEmployees() async {
            errorMessage = ""
            do {
                employees = try await repository.getAll()
            } catch {
                errorMessage = "\(error)"
            }
        }
    }
}

#Preview {
    ContentView()
}
