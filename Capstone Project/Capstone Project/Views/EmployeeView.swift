//
//  EmployeeView.swift
//  Capstone Project
//
//  Created by user301577 on 9/28/26.
//

import SwiftUI

struct EmployeeList: View {
        
    @Environment(\.employeeRepository) var employeeRepository
    @State var viewModel: ViewModel
    
    init(repository: any RepositoryProtocol<Employee>) {
        _viewModel = State(wrappedValue: ViewModel(repository: repository))
    }
    
    
    
    var body: some View {
        VStack {
            BannerError(model: viewModel)
            
            VStack(spacing: 6) {
                Text("Employee Directory")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)
                ZStack {
                    HStack {
                        Text("Filter")
                        TextField("Name/Dept/ID", text: $viewModel.filter)
                        Menu {
                            Picker("Sort by", selection: $viewModel.sortOption) {
                                ForEach(ViewModel.SortOption.allCases, id: \.self) { option in
                                    Text(option.rawValue)
                                        .tag(option)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .accessibilityLabel("Sort employees")
                        }
                    }
                    
                    .fixedSize(horizontal: true, vertical: false)
                }
                .frame(maxWidth: .infinity)
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
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        
                        if let title = employee.title, title.isEmpty == false {
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
                    
                    if let department = employee.department, department.isEmpty == false {
                        Text(department)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.trailing)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 8)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        viewModel.selectedEmployee = employee
                    }
                }
                .listRowBackground(rowBackground(for: employee))
            }
            
            
            
            .frame(maxWidth: .infinity)
            
            Divider()
            
            detailPanel
                .frame(maxWidth: .infinity)
            
        }
        .task {
            await viewModel.loadEmployees()
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
                    HStack {
                        Text("Employee ID")
                            .font(.subheadline).bold()
                        Text(" - ")
                        Spacer(minLength: 16)
                        Text("\(employee.employeeId)")
                            .font(.subheadline)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    HStack {
                        Text("Job Title")
                            .font(.subheadline).bold()
                        Text(" - ")
                        Spacer(minLength: 16)
                        Text(employee.jobTitle)
                            .font(.subheadline)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    HStack {
                        Text("Shift")
                            .font(.subheadline).bold()
                        Text(" - ")
                        Spacer(minLength: 16)
                        Text(employee.shift ?? "")
                            .font(.subheadline)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    HStack {
                        Text("Hire Date")
                            .font(.subheadline).bold()
                        Text("-")
                        Spacer(minLength: 16)
                        Text(employee.hireDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                            .font(.subheadline)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .background(.background, in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .transition(.move(edge: .bottom))

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
                    .lowercased()
                    .contains(filter.lowercased()) ||
                (employee.department ?? "")
                    .lowercased()
                    .contains(filter.lowercased()) ||
                String(employee.employeeId)
                    .contains(filter)
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
        
        var selectedEmployee: Employee? = nil
        
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
