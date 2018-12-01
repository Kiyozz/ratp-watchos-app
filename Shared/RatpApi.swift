//
//  RaptApi.swift
//  RatpMetro
//
//  Created by Kévin TURMEL on 01/12/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import Foundation

public struct Schedule : Decodable {
    let message: String
    let destination: String
}

struct RatpScheduleResponse {
    let schedules: [Schedule]
    
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

extension RatpScheduleResponse : Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        let resultContainer = try container.nestedContainer(keyedBy: ResultKeys.self, forKey: .result)
        
        var schedulesContainer = try resultContainer.nestedUnkeyedContainer(forKey: .schedules)
        var schedules = [Schedule]()
        
        while !schedulesContainer.isAtEnd {
            let scheduleMessagesContainer = try schedulesContainer.nestedContainer(keyedBy: MessageKeys.self)
            let schedule = Schedule(message: try scheduleMessagesContainer.decode(String.self, forKey: .message), destination: try scheduleMessagesContainer.decode(String.self, forKey: .destination))
            
            schedules.append(schedule)
        }
        
        self.schedules = schedules
    }
}

public enum RatpLines: Int {
    case m4 = 4
    case m6 = 6
}

public enum RatpScheduleDirection: String {
    case A, R
}

public struct RatpApiError : Error {
    enum Kind {
        case noData, unknown, jsonParse
    }
    
    let kind: Kind
    let message: String?
}

public class RatpApi {
    private let apiUrl = "https://api-ratp.pierre-grimaud.fr/v3"
    private let montparnasse = "montparnasse+bienvenue"
    
    public func getSchedules(forLine line: RatpLines, to direction: RatpScheduleDirection, handler: @escaping ([Schedule]?, Error?) -> Void) -> URLSessionTask {
        let fetch = Fetch()

        let task = fetch.get(url: "\(apiUrl)/schedules/metros/\(line.rawValue)/\(montparnasse)/\(direction.rawValue)", handler: { (data, response, error) in
            if error != nil {
                handler(nil, RatpApiError(kind: .unknown, message: error!.localizedDescription))
            }
            
            guard let data = data else {
                handler(nil, RatpApiError(kind: .noData, message: "Data cannot be retrieve from Api"))
                
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let payload = try decoder.decode(RatpScheduleResponse.self, from: data)
                
                handler(payload.schedules, nil)
            } catch {
                handler(nil, RatpApiError(kind: .jsonParse, message: "JSON Response cannot be parsed"))
                
                return
            }
        })
        
        return task
    }
}
