//
//  RaptApi.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 01/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//
// type = metros
// code = 4 or 6
// station to be defined
// way = A or R
// Maybe get the name of destination (-> Porte ... or -> Bastille etc instead of A or R)
// https://api-ratp.pierre-grimaud.fr/v3/documentation#get--schedules-{type}-{code}-{station}-{way}

import Foundation

public struct RatpSchedule: Decodable {
  let message: String
  let destination: String
}

struct RatpScheduleResponse {
  let schedules: [RatpSchedule]
  
  enum RootKeys: String, CodingKey {
    case result
  }
  
  enum ResultKeys: String, CodingKey {
    case schedules
  }
  
  enum MessageKeys: String, CodingKey {
    case message, destination
  }
}

extension RatpScheduleResponse: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootKeys.self)
    
    let resultContainer = try container.nestedContainer(keyedBy: ResultKeys.self, forKey: .result)
    
    var schedulesContainer = try resultContainer.nestedUnkeyedContainer(forKey: .schedules)
    var schedules = [RatpSchedule]()
    
    while !schedulesContainer.isAtEnd {
      let scheduleMessagesContainer = try schedulesContainer.nestedContainer(keyedBy: MessageKeys.self)
      let schedule = RatpSchedule(message: try scheduleMessagesContainer.decode(String.self, forKey: .message), destination: try scheduleMessagesContainer.decode(String.self, forKey: .destination))
      
      schedules.append(schedule)
    }
    
    self.schedules = schedules
  }
}

public enum RatpLine: Int {
  case m4 = 4
  case m6 = 6
}

public enum RatpDirection: String {
  case A, R
}

public struct RatpApiError: Error {
  enum Kind {
    case noData, unknown, jsonParse
  }
  
  let kind: Kind
  let message: String?
}

public class RatpApi: Fetch {
  private let apiUrl = "https://api-ratp.pierre-grimaud.fr/v3"
  private let montparnasse = "montparnasse+bienvenue"
  
  ///
  /// Get all schedules forLine and to direction
  ///
  /// - parameters:
  ///   - line: Line to get data
  ///   - direction: Direction of the schedule
  ///   - then: Closure called with data and any error
  ///
  public func schedules(
    forLine line: RatpLine,
    to direction: RatpDirection,
    then: @escaping ([RatpSchedule]?, Error?) -> Void
    ) -> URLSessionTask {
    return get(url: "\(apiUrl)/schedules/metros/\(line.rawValue)/\(montparnasse)/\(direction.rawValue)", handler: { (data, response, error) in
      if error != nil {
        then(nil, RatpApiError(kind: .unknown, message: error!.localizedDescription))
        
        return
      }
      
      guard let data = data else {
        then(nil, RatpApiError(kind: .noData, message: "Data cannot be retrieve from Api"))
        
        return
      }
      
      let decoder = JSONDecoder()
      
      do {
        let payload = try decoder.decode(RatpScheduleResponse.self, from: data)
        
        then(payload.schedules, nil)
      } catch {
        then(nil, RatpApiError(kind: .jsonParse, message: "JSON Response cannot be parsed"))
        
        return
      }
    })
  }
}
