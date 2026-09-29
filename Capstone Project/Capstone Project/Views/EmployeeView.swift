//
//  EmployeeView.swift
//  Capstone Project
//
//  Created by user301577 on 9/28/26.
//

import SwiftUI

struct EmployeeList: View {
    
    @State private var viewModel: ViewModel
    
    init(repository: any RepositoryProtocol<Employee>) {
        viewModel = ViewModel(repository: repository)
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
            
            List(viewModel.employees) { employee in
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
                    viewModel.selectedEmployee = employee
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
        
    }
    
}

extension EmployeeList {
    
    @Observable
    class ViewModel: Failable {
        
        private let repository: any RepositoryProtocol<Employee>
        
        init(repository: any RepositoryProtocol<Employee>) {
            self.repository = repository
        }
        
        var errorMessage: String = ""
        
        var employees: [Employee] = [] {
            didSet {
                selectedEmployee = nil
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
    EmployeeList(repository: RemoteEmployeeDirectoryRepository(urlBase: "https://api.bootcampcentral.com/employee"))
}
