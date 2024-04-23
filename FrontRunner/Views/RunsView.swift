//
//  RunsView.swift
//  FrontRunner
//
//  Created by Oscar Epp on 4/23/24.
//

import SwiftUI

struct RunsView: View {
    @StateObject private var vm = CloudKitCrudRunningViewModel()
    @State var showingSheet = true
    
    var body: some View {
        VStack {
            header
            HStack {
//                textField
                addButton
            }
            Text("Hello, World!")
        }
        
        .sheet(isPresented: $showingSheet) {
            AddRunSheet(vm: vm, showingSheet: $showingSheet)
        }
    }
}

extension RunsView {
    private var header: some View {
        Text("Runs")
            .font(.headline)
            .underline()
    }
    
    private var addButton: some View {
        Button {
            showingSheet = true
        } label: {
            Text("Add")
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 55, height: 55)
                .background(Color.green)
                .cornerRadius(10)
        }
    }
}

struct AddRunSheet: View {
    @ObservedObject var vm: CloudKitCrudRunningViewModel
    @Binding var showingSheet: Bool

    // Adding additional state properties for new inputs
    @State private var name: String = ""
    @State private var distance: String = ""
    @State private var pace: String = ""
    @State private var description: String = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Run Information")) {
//                    TextField("Run Name", text: $vm.text)
                    TextField("Run Name", text: $name)
                    TextField("Distance (mi)", text: $distance)
                        .keyboardType(.decimalPad)
                    TextField("Pace (min/mi)", text: $pace)
                        .keyboardType(.decimalPad)
                    TextField("Description", text: $description)
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    Button(action: {
//                        vm.saveRunData(name: vm.text, distance: vm.distance, pace: vm.pace, description: vm.description, date: vm.date)
                        vm.saveRunData(name: vm.text)
                        showingSheet = false
                    }) {
                        Text("Add Run Details")
                            .bold()
                    }
                    Button("Cancel") {
                        showingSheet = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Run Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
    }
}


#Preview {
    RunsView()
}
