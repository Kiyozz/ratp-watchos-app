//
//  Fetch.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 26/11/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation

public class Fetch {
    public static func get(url: String, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        let urlObject = URL(string: url)
        var request = URLRequest(url: urlObject!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let task = URLSession.shared.dataTask(with: request, completionHandler: handler)
        
        task.resume()
        
        return task
    }
}
