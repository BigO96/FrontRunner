//
//  TestView.swift
//  FrontRunner
//
//  Created by Oscar Epp on 4/22/24.
//

import SwiftUI
import CloudKit
import Combine

protocol CloudKitableProtocol {
    init?(record: CKRecord)
    var record: CKRecord { get }
}

//struct CloudKitFruitModelNames {
//    static let name = "name"
//}

struct FruitModel: Hashable, CloudKitableProtocol {
    let name: String
    let count: Int
    let imageURL: URL?
    let record: CKRecord
    
    init?(record: CKRecord) {
        guard let name = record["name"] as? String else { return nil }
        self.name = name
        let count = record["count"] as? Int
        self.count = count ?? 0
        let imageAsset = record["image"] as? CKAsset
        self.imageURL = imageAsset?.fileURL
        self.record = record
    }
    
    init?(name: String, imageURL: URL?, count: Int?) {
        let record = CKRecord(recordType: "Fruits")
        record["name"] = name
        if let url = imageURL {
            let asset = CKAsset(fileURL: url)
            record["image"] = asset
        }
        if let count = count {
            record["count"] = count
        }
        self.init(record: record)
    }
    
    func update(newName: String) -> FruitModel? {
        let record = record
        record["name"] = newName
        return FruitModel(record: record)
    }
    
}

class CloudKitCrudRunningViewModel: ObservableObject {
    
    @Published var text: String = ""
    @Published var fruits: [FruitModel] = []
    var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchItems()
    }
    
    func addButtonPressed() {
        guard !text.isEmpty else { return }
        addItem(name: text)
    }
    
    private func addItem(name: String) {
        guard
            let image = UIImage(named: "IMG_1811"),
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("IMG_1811.jpg"),
            let data = image.jpegData(compressionQuality: 1.0) else { return }
        
        do {
            try data.write(to: url)
            guard let newFruit = FruitModel(name: name, imageURL: url, count: 5) else { return }

            CloudKitUtility.add(item: newFruit) { result in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fetchItems() /// Fix at 1:18:00
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        let recordType = "Fruits"
        CloudKitUtility.fetch(predicate: predicate, recordType: recordType, sortDescriptions: nil, resultsLimit: nil)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] returnedItems in
                self?.fruits = returnedItems
            }
            .store(in: &cancellables)
    }
    

    func updateItem(fruit: FruitModel) {
        guard let newFruit = fruit.update(newName: "Woah!") else { return }
        CloudKitUtility.update(item: newFruit) { [weak self] result in
            print("UPDATE COMPLETED")
            self?.fetchItems()
        }
    }
    
    func deleteItem(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let fruit = fruits[index]
        
        CloudKitUtility.delete(item: fruit)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] success in
                print("Deleted: \(success)")
                self?.fruits.remove(at: index)
            }
            .store(in: &cancellables)
    }
}


struct RunningView: View {
    
    @StateObject private var vm = CloudKitCrudRunningViewModel()
    
    var body: some View {
        NavigationView {
            VStack{
                header
                textField
                addButton
                
                List {
                    ForEach(vm.fruits, id: \.self) { fruit in
                        HStack {
                            Text(fruit.name)
                            
                            if let url = fruit.imageURL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 50, height: 50)
                            }
                        }
                        .onTapGesture {
                            vm.updateItem(fruit: fruit)
                        }
                    }
                    .onDelete(perform: vm.deleteItem)
                }
                .listStyle(PlainListStyle())
            }
            .padding()
            .navigationBarBackButtonHidden(true)
        }
    }
    
}

#Preview {
    RunningView()
}


extension RunningView{
    private var header: some View {
        Text("CloudKit CRUD ☁️")
            .font(.headline)
            .underline()
    }
    
    private var textField: some View {
        TextField("Add Something Here...", text: $vm.text)
            .frame(height: 55)
            .padding(.leading)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
    }
    
    private var addButton: some View {
        Button {
            vm.addButtonPressed()
        } label: {
            Text("Add")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(10)
        }
    }
}
