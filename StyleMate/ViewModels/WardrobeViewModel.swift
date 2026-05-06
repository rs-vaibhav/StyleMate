import Foundation
import SwiftUI

class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = [] {
        didSet { save() }
    }
    
    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("wardrobe.json")
    }
    
    init() {
        load()
    }
    
    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let saved = try? JSONDecoder().decode([WardrobeItem].self, from: data) else { return }
        items = saved
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }
    
    func addItem(_ item: WardrobeItem) {
        items.append(item)
    }
    
    func updateItem(_ item: WardrobeItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func deleteItem(_ item: WardrobeItem) {
        items.removeAll { $0.id == item.id }
        // Delete photo if exists
        if let filename = item.photoFilename {
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let photoURL = docs.appendingPathComponent(filename)
            try? FileManager.default.removeItem(at: photoURL)
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            if let filename = items[index].photoFilename {
                let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let photoURL = docs.appendingPathComponent(filename)
                try? FileManager.default.removeItem(at: photoURL)
            }
        }
        items.remove(atOffsets: offsets)
    }
    
    func items(for category: ClothingCategory) -> [WardrobeItem] {
        items.filter { $0.category == category }
    }
    
    func savePhoto(_ imageData: Data) -> String {
        let filename = UUID().uuidString + ".jpg"
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(filename)
        try? imageData.write(to: url)
        return filename
    }
    
    func loadPhoto(filename: String) -> UIImage? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    var topCount: Int { items(for: .top).count }
    var bottomCount: Int { items(for: .bottom).count }
    var footwearCount: Int { items(for: .footwear).count }
    var accessoryCount: Int { items(for: .accessory).count }
}
