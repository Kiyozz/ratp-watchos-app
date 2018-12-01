//
//  MetroInterfaceController.swift
//  RatpMetro WatchKit Extension
//
//  Created by Kévin TURMEL on 26/11/2018.
//  Copyright © 2018 Kévin TURMEL. All rights reserved.
//

import WatchKit
import Foundation

class MetroInterfaceController: WKInterfaceController {
    @IBOutlet weak var lineTable: WKInterfaceTable!
    @IBOutlet weak var noLineSelectedGroup: WKInterfaceGroup!
    
    let api = RatpApi()
    let interval : TimeInterval = 40.0

    var timer: Timer? = nil {
        willSet {
            timer?.invalidate()
        }
    }

    var m4FetchTask: URLSessionTask? {
        willSet {
            m4FetchTask?.cancel()
        }
    }
    
    var m4FetchRTask: URLSessionTask? {
        willSet {
            m4FetchRTask?.cancel()
        }
    }

    var m6FetchTask: URLSessionTask? {
        willSet {
            m6FetchTask?.cancel()
        }
    }
    
    var m6FetchRTask: URLSessionTask? {
        willSet {
            m6FetchRTask?.cancel()
        }
    }
    
    var m4Active: Bool = false
    var m6Active: Bool = false
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        print("WillActivate")
        
        m4Active = UserDefaults.standard.bool(forKey: UserDefaultsKeys.m4) // Get User choosen line
        m6Active = UserDefaults.standard.bool(forKey: UserDefaultsKeys.m6) // Get User choosen line
        
        if lineTable.numberOfRows != numberOfActiveLines() { // Empty the lineTable if switched from Options Page and change number of active lines
            for i in 0...lineTable.numberOfRows {
                lineTable.removeRows(at: [i])
            }
            
            lineTable.setHidden(true)
            lineTable.setNumberOfRows(numberOfActiveLines(), withRowType: "LineRowType")
        }
        
        callFetch(m4: m4Active, m6: m6Active) // Call API
        startTimer() // Start the interval timer
        
        if !m4Active && !m6Active {
            noLineSelectedGroup.setHidden(false)
        } else {
            noLineSelectedGroup.setHidden(true) // Display no line label if no line is selected in options
        }
    }

    override func willDisappear() {
        super.willDisappear()
        
        print("Disappear")

        timer = nil // Cancel the interval

        taskM4Done() // Mark all task as cancelled
        taskM4RDone()
        taskM6Done()
        taskM6RDone()
    }
    
    func startTimer() {
        if let _ = timer { // Do not create a new timer if another one exists
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
            self.callFetch(m4: self.m4Active, m6: self.m6Active) // After self.interval passed, call API
        })
    }
    
    func handleSchedules(for line: RatpLines, and direction: RatpScheduleDirection, with schedules: [Schedule]?) {
        guard let schedules = schedules else { return } // If no schedules, do nothing
        
        lineTable.setHidden(false) // Display the table if it was hidden

        guard let activeIndex = getControllerIndex(forLine: line, to: direction) else { return }

        let row = lineTable.rowController(at: activeIndex) as! LineRowType
        
        let firstSchedule = schedules[0] // Get the first schedule
        let secondSchedule = schedules[1] // Get the second schedule
        
        row.lineGroup.setHidden(false) // Display the group
        row.firstLabel.setText(firstSchedule.message) // Change the text with schedule's
        row.secondLabel.setText(secondSchedule.message) // Change the text with schedule's
        row.titleLabel.setText(firstSchedule.destination) // Change the direction with schedule's
        row.lineImage.setImageNamed("m\(line.rawValue).png") // Change the image with schedule's
    }
    
    func callFetch (m4: Bool, m6: Bool) {
        print("fetch")
        if m4Active {
            if m4FetchTask == nil {
                print("fetch m4A")
                m4FetchTask = api.getSchedules(forLine: .m4, to: .A, handler: { (schedules, error) in
                    if error != nil {
                        print(error!)
                    }
                    
                    self.handleSchedules(for: .m4, and: .A, with: schedules)
                    self.taskM4Done()
                })
            }
            
            if m4FetchRTask == nil {
                print("fetch m4R")
                m4FetchRTask = api.getSchedules(forLine: .m4, to: .R, handler: { (schedules, error) in
                    if error != nil {
                        print(error!)
                    }
                    
                    self.handleSchedules(for: .m4, and: .R, with: schedules)
                    self.taskM4RDone()
                })
            }
        }
        
        if m6Active {
            if m6FetchTask == nil {
                print("fetch m6A")
                m6FetchTask = api.getSchedules(forLine: .m6, to: .A, handler: { (schedules, error) in
                    if error != nil {
                        print(error!)
                    }
                    
                    self.handleSchedules(for: .m6, and: .A, with: schedules)
                    self.taskM6Done()
                })
            }
            
            if m6FetchRTask == nil {
                print("fetch m6R")
                m6FetchRTask = api.getSchedules(forLine: .m6, to: .R, handler: { (schedules, error) in
                    if error != nil {
                        print(error!)
                    }
                    
                    self.handleSchedules(for: .m6, and: .R, with: schedules)
                    self.taskM6RDone()
                })
            }
        }
    }
    
    func taskM4Done() {
        m4FetchTask = nil
    }
    
    func taskM6Done() {
        m6FetchTask = nil
    }
    
    func taskM4RDone() {
        m4FetchRTask = nil
    }
    
    func taskM6RDone() {
        m6FetchRTask = nil
    }
    
    func numberOfActiveLines() -> Int {
        if !m4Active && !m6Active {
            return 0
        }
        
        if m4Active && m6Active {
            return 4
        }
        
        return 2
    }
    
    func getControllerIndex(forLine line: RatpLines, to direction: RatpScheduleDirection) -> Int? {
        switch lineTable.numberOfRows { // Depends of number of rows, the rowController index changes
        case 2:
            if direction == .A {
                return 0
            } else {
                return 1
            }
        case 0:
            return nil
        default:
            if m4Active && line == .m4 && direction == .A {
                return 0
            } else if m4Active && line == .m4 && direction == .R {
                return 1
            } else if m6Active && line == .m6 && direction == .A {
                return 2
            } else {
                return lineTable.numberOfRows - 1
            }
        }
    }
}
