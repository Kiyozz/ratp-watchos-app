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
  func get(handler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) -> URLSessionTask
}

protocol RequestFactory {
  ///
  /// Make a new HTTP Request
  ///
  func makeRequest() -> URLRequest
}

// MARK: - RequestFactory
extension URL: RequestFactory {
  func makeRequest() -> URLRequest {
    var request = URLRequest(url: self)
    request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
    
    return request
  }
}

// MARK: - Fetchable
extension URL: Fetchable {
  public func get(handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
    let request = makeRequest()
    let task = URLSession.shared.dataTask(with: request, completionHandler: handler)
    
    task.resume()
    
    return task
  }
}
