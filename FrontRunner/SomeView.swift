//
//  SomeView.swift
//  FrontRunner
//
//  Created by Oscar Epp on 4/23/24.
//

import SwiftUI
import Combine

class CloudKitUserBootcampViewModel: ObservableObject {
    
    @Published var permissionStatus: Bool = false
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    @Published var userName: String = ""
    var cancellable = Set<AnyCancellable>()
    
    init() {
        getiCloudStatus()
        requestPermission()
        getCurrentUserName()
    }
    
    private func getiCloudStatus() {
        CloudKitUtility.getiCloudStatus()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] success in
                self?.isSignedInToiCloud = success
            }
            .store(in : &cancellable)
    }
    
    
    func requestPermission() {
        CloudKitUtility.requestApplicationPermission()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] success in
                self?.permissionStatus = success
            }
            .store(in: &cancellable)
            
    }
    
    func getCurrentUserName() {
        CloudKitUtility.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedName in
                self?.userName = returnedName
            }
            .store(in: &cancellable)
    }
    
}



struct CloudKitUserBootcamp: View {
    
    @StateObject private var vm = CloudKitUserBootcampViewModel()
    
    var body: some View {
        Text("IS SIGNED IN : \(vm.isSignedInToiCloud.description.uppercased())")
        Text(vm.error)
        Text("Permission \(vm.permissionStatus.description.uppercased())")
        Text("NAME: \(vm.userName)")
    }
}

#Preview {
    CloudKitUserBootcamp()
}
