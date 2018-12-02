//
//  Fetch.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 26/11/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation

protocol Fetchable {
  ///
  /// HTTP GET Request
  /// - parameters:
  ///   - url: URL to fetch the data
  ///   - handler: Closure called when HTTP Request ends
  ///   - data: Data retrieve from API
  ///   - response: HTTP Response
  ///   - error: Any error thrown from HTTP
  ///
  func get(url: String, handler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionTask
}

protocol RequestFactory {
  ///
  /// Make a new HTTP Request
  ///
  /// - parameters:
  ///   - url: URL to Fetch
  func makeRequest(forUrl url: String) -> URLRequest
}

public class Fetch {
}

// MARK: - RequestFactory
extension Fetch: RequestFactory {
  func makeRequest(forUrl url: String) -> URLRequest {
    let urlObject = URL(string: url)
    var request = URLRequest(url: urlObject!)
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    return request
  }
}

// MARK: - Fetchable
extension Fetch: Fetchable {
  public func get(url: String, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
    let request = makeRequest(forUrl: url)
    let task = URLSession.shared.dataTask(with: request, completionHandler: handler)
    
    task.resume()
    
    return task
  }
}
