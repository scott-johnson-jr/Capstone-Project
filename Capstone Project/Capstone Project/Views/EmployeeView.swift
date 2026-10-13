
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
                    .accessibilityAddTraits(.isHeader) // NOTE: Identifies the title as a screen header for VoiceOver
                
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
                let isSelected = viewModel.selectedEmployee?.id == employee.id
                
                HStack(alignment: .center, spacing: 12) {
                    // NOTE: Added checkmark icon for Color Independence.
                    // Users who can't distinguish background color can now see selection state.
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                        .accessibilityHidden(true) // Hidden from VoiceOver since state is handled by row accessibility value below
                    
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
                .frame(minHeight: 44) // NOTE: Enforces minimum 44pt height for touch target accessibility
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        viewModel.selectedEmployee = employee
                    }
                }
                .listRowBackground(rowBackground(for: employee))
                // NOTE: VoiceOver accessibility modifiers combined to read row as a single clear element
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(employee.firstName) \(employee.lastName), Department: \(employee.department ?? "None")")
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
                   // NOTE: Combined detail row so VoiceOver reads "Employee ID: [value]" cleanly instead of reading the hyphen "-" separately
                   .accessibilityElement(children: .combine)
                   .accessibilityLabel("Employee ID: \(employee.employeeId)")
                    
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
                   // NOTE: Combined job title row for screen readers
                   .accessibilityElement(children: .combine)
                   .accessibilityLabel("Job Title: \(employee.jobTitle)")
                    
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
                   // NOTE: Combined shift row for screen readers
                   .accessibilityElement(children: .combine)
                   .accessibilityLabel("Shift: \(employee.shift ?? "None")")
                    
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
                   // NOTE: Combined hire date row for screen readers
                   .accessibilityElement(children: .combine)
                   .accessibilityLabel("Hire Date: \(employee.hireDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
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
    ContentView()
}
