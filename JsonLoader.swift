//
//  JsonLoader.swift
//  ChatDemo
//
//  Created by Bibin on 30/12/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import Foundation

class JsonLoader {
    static func loadFrom<T: Codable>(file: String) -> T {
        let data: Data = self.loadFrom(file: file)
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            return model
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
    }
    
    static func loadFrom(file: String) -> [String: Any] {
        do {
            let data: Data = self.loadFrom(file: file)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            return (jsonResult as? [String: Any]) ?? [:]
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
    }
    
    static func loadFrom(file: String) -> Data {
        let bundle = Bundle(for: Self.self)
        let path = bundle.path(forResource: file, ofType: "json")!
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        } catch {
            print(error)
            fatalError(error.localizedDescription)
        }
    }
    
}


