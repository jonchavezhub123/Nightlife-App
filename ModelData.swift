//
//  ModelData.swift
//  Nightlife
//
//  Created by Jhon Chavez on 10/7/24.
//
/*
import Foundation

@Observable
class ModelData {
    var bars: [Bar]

    init() {
        print("Initializing ModelData")
        self.bars = load("chicago_bars_two.json")
        print("Loaded \(self.bars.count) bars")
    }
}

func load(_ filename: String) -> [Bar] {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode([Bar].self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as [Bar]:\n\(error)")
    }
}
*/

/*
import Foundation

@Observable
class ModelData {
    var bars: [Bar] = []

    init() {
        print("Initializing ModelData")
        loadBars()
        print("Loaded \(self.bars.count) bars")
    }
    
    func loadBars() {
        do {
            self.bars = try load("chicago_bars_two.json")
        } catch {
            print("Error loading bars: \(error)")
        }
    }
}

func load(_ filename: String) throws -> [Bar] {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find \(filename) in main bundle."])
    }
    
    do {
        let data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        return try decoder.decode([Bar].self, from: data)
    } catch {
        print("Error decoding JSON: \(error)")
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .valueNotFound(let value, let context):
                print("Value '\(value)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error")
            }
        }
        throw error
    }
}
*/
/*
import Foundation

@Observable
class ModelData {
    var bars: [Bar] = []

    init() {
        print("Initializing ModelData")
        loadBars()
        print("Loaded \(self.bars.count) bars")
        
        // Debug: Print the first few bars
        for (index, bar) in bars.prefix(5).enumerated() {
            print("Bar \(index + 1):")
            print("  Name: \(bar.name)")
            print("  Latitude: \(bar.latitude), Longitude: \(bar.longitude)")
        }
    }
    
    func loadBars() {
        do {
            self.bars = try load("chicago_bars_two.json")
        } catch {
            print("Error loading bars: \(error)")
        }
    }
}

func load(_ filename: String) throws -> [Bar] {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find \(filename) in main bundle."])
    }
    
    do {
        let data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        return try decoder.decode([Bar].self, from: data)
    } catch {
        print("Error decoding JSON: \(error)")
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .valueNotFound(let value, let context):
                print("Value '\(value)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error")
            }
        }
        throw error
    }
}

*/
import Foundation

@Observable
class ModelData {
    var bars: [Bar] = []

    init() {
        print("Initializing ModelData")
        loadBars()
        print("Loaded \(self.bars.count) bars")
        
        // Debug: Print the first few bars
        for (index, bar) in bars.prefix(5).enumerated() {
            print("Bar \(index + 1):")
            print("  Name: \(bar.name)")
            print("  Latitude: \(bar.latitude), Longitude: \(bar.longitude)")
        }
    }
    
    func loadBars() {
        do {
            self.bars = try load("chicago_bars_two.json")
        } catch {
            print("Error loading bars: \(error)")
        }
    }
}

func load(_ filename: String) throws -> [Bar] {
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        throw NSError(domain: "FileError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find \(filename) in main bundle."])
    }
    
    do {
        let data = try Data(contentsOf: file)
        print("File contents:")
        if let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString.prefix(500)) // Print first 500 characters
        } else {
            print("Unable to convert data to string")
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([Bar].self, from: data)
    } catch {
        print("Error decoding JSON: \(error)")
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .valueNotFound(let value, let context):
                print("Value '\(value)' not found: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .typeMismatch(let type, let context):
                print("Type '\(type)' mismatch: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            case .dataCorrupted(let context):
                print("Data corrupted: \(context.debugDescription)")
                print("codingPath: \(context.codingPath)")
            @unknown default:
                print("Unknown decoding error")
            }
        }
        throw error
    }
}
