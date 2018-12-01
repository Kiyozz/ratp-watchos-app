//
//  Fetch.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 26/11/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
// type = metros
// code = 4 or 6
// station to be defined
// way = A or R
// Maybe get the name of destination (-> Porte ... or -> Bastille etc instead of A or R)
// https://api-ratp.pierre-grimaud.fr/v3/documentation#get--schedules-{type}-{code}-{station}-{way}
//

import Foundation

public class Fetch {
    public func get(url: String, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        let urlObject = URL(string: url)
        var request = URLRequest(url: urlObject!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        let task = URLSession.shared.dataTask(with: request, completionHandler: handler)

        task.resume()
        
        return task
    }
}
