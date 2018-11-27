//
//  JsonDecodeWrapper.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 27/11/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation

public class JsonDecodeWrapper {
    public func decode<T>(type: T.Type, from data: Data) -> T? where T : Decodable {
        do {
            let decoder = JSONDecoder()
            let data = try decoder.decode(type, from: data)
            
            return data
        } catch {
            return nil
        }
    }
}
