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

public struct RatpStation: Decodable {
  let slug: String
  let name: String
}

public struct RatpSchedule: Decodable {
  let message: String
  let destination: String
}

class RatpResponse {
  enum RootKeys: String, CodingKey {
    case result
  }
}

final class RatpScheduleResponse: RatpResponse {
  let schedules: [RatpSchedule]

  enum ResultKeys: String, CodingKey {
    case schedules
  }
  
  enum MessageKeys: String, CodingKey {
    case message, destination
  }
  
  init(schedules: [RatpSchedule]) {
    self.schedules = schedules
  }
}

final class RatpStationResponse: RatpResponse {
  let stations: [RatpStation]
  
  enum ResultKeys: String, CodingKey {
    case stations
  }
  
  enum StationKeys: String, CodingKey {
    case slug, name
  }
  
  init(stations: [RatpStation]) {
    self.stations = stations
  }
}

extension RatpScheduleResponse: Decodable {
  convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootKeys.self)
    
    let resultContainer = try container.nestedContainer(keyedBy: ResultKeys.self, forKey: .result)
    
    var schedulesContainer = try resultContainer.nestedUnkeyedContainer(forKey: .schedules)
    var schedules = [RatpSchedule]()
    
    while !schedulesContainer.isAtEnd {
      let scheduleMessagesContainer = try schedulesContainer.nestedContainer(keyedBy: MessageKeys.self)
      let schedule = RatpSchedule(message: try scheduleMessagesContainer.decode(String.self, forKey: .message), destination: try scheduleMessagesContainer.decode(String.self, forKey: .destination))
      
      schedules.append(schedule)
    }
    
    self.init(schedules: schedules)
  }
}

extension RatpStationResponse: Decodable {
  convenience init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: RootKeys.self)
    
    let resultContainer = try container.nestedContainer(keyedBy: ResultKeys.self, forKey: .result)
    
    var stationsContainer = try resultContainer.nestedUnkeyedContainer(forKey: .stations)
    var stations = [RatpStation]()
    
    while !stationsContainer.isAtEnd {
      let stationContainer = try stationsContainer.nestedContainer(keyedBy: StationKeys.self)
      let station = RatpStation(slug: try stationContainer.decode(String.self, forKey: .slug), name: try stationContainer.decode(String.self, forKey: .name))
      
      stations.append(station)
    }
    
    self.init(stations: stations)
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

public class RatpApi {
  private let apiUrl = "https://api-ratp.pierre-grimaud.fr/v3"
  
  private func unknownError(_ error: Error) -> Error {
    return RatpApiError(kind: .unknown, message: error.localizedDescription)
  }
  
  private func noDataError() -> Error {
    return RatpApiError(kind: .noData, message: "Data cannot be retrieve from Api")
  }
  
  private func jsonParseError() -> Error {
    return RatpApiError(kind: .jsonParse, message: "JSON Response cannot be parsed")
  }
  
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
    forStation station: String,
    then: @escaping ([RatpSchedule]?, Error?) -> Void
  ) -> URLSessionTask {
    let url = URL(string: "\(apiUrl)/schedules/metros/\(line.rawValue)/\(station)/\(direction.rawValue)")!
    
    return url.get(handler: { (data, response, error) in
      if error != nil {
        then(nil, self.unknownError(error!))
        
        return
      }
      
      guard let data = data else {
        then(nil, self.noDataError())
        
        return
      }
      
      let decoder = JSONDecoder()
      
      DispatchQueue.main.async {
        do {
          let payload = try decoder.decode(RatpScheduleResponse.self, from: data)
          
          then(payload.schedules, nil)
        } catch {
          then(nil, self.jsonParseError())
        }
      }
      
      return
    })
  }
  
  public func stations(
    forLine line: RatpLine,
    then: @escaping ([RatpStation]?, Error?) -> Void
  ) -> URLSessionTask {
    let url = URL(string: "\(apiUrl)/stations/metros/\(line.rawValue)")!
    
    return url.get { (data, response, error) in
      if error != nil {
        then(nil, self.unknownError(error!))
      }
      
      guard let data = data else {
        then(nil, self.noDataError())
        
        return
      }
      
      let decoder = JSONDecoder()
      
      DispatchQueue.main.async {
        do {
          let payload = try decoder.decode(RatpStationResponse.self, from: data)
          
          then(payload.stations, nil)
        } catch {
          then(nil, self.jsonParseError())
        }
      }
    }
  }
}
