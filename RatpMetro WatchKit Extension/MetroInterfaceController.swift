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
  @IBOutlet weak var ratpLinesTable: WKInterfaceTable!
  @IBOutlet weak var noLineSelectedGroup: WKInterfaceGroup!

  let debug = Debug(from: "MetroInterfaceController")
  let api = RatpApi()
  let interval: TimeInterval = 40.0
  
  ///
  /// Invalidate the timer if the timer changes
  ///
  var timer: Timer? = nil {
    willSet {
      timer?.invalidate()
    }
  }
  
  ///
  /// Cancel the session task if the task changes
  ///
  var m4SessionTask: URLSessionTask? {
    willSet {
      m4SessionTask?.cancel()
    }
  }
  
  ///
  /// Cancel the session task if the task changes
  ///
  var m4RSessionTask: URLSessionTask? {
    willSet {
      m4RSessionTask?.cancel()
    }
  }
  
  ///
  /// Cancel the session task if the task changes
  ///
  var m6SessionTask: URLSessionTask? {
    willSet {
      m6SessionTask?.cancel()
    }
  }
  
  ///
  /// Cancel the session task if the task changes
  ///
  var m6RSessionTask: URLSessionTask? {
    willSet {
      m6RSessionTask?.cancel()
    }
  }

  let preferences = UserPreferences()

  var m4Active: Bool {
    return preferences.m4Active
  }
  
  var m6Active: Bool {
    return preferences.m6Active
  }
  
  var m4Station: String {
    return preferences.stationM4
  }
  
  var m6Station: String {
    return preferences.stationM6
  }
  
  var lastM4Station: String?
  var lastM6Station: String?

  var numberOfActiveLines: Int {
    if !m4Active && !m6Active {
      return 0
    }
    
    if m4Active && m6Active {
      return 4
    }
    
    return 2
  }
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    
    debug.log("Awake")
    
    lastM4Station = m4Station
    lastM6Station = m6Station
  }
  
  override func willActivate() {
    super.willActivate()
    
    debug.log("WillActivate")

    // Empty the lineTable if switched from OptionsInterfaceController and number of active lines changed
    if ratpLinesTable.numberOfRows != numberOfActiveLines || lastM4Station != m4Station || lastM6Station != m6Station {
      resetTable()
    }

    // Call API
    fetchApiData()
    
    // Do not create a new timer if another one exists
    if timer == nil {
      // Start the interval timer
      startTimer()
    }

    // If no line is selected, display the right text
    handleNoLineSelected()
  }
  
  override func willDisappear() {
    super.willDisappear()
    
    debug.log("Disappear")
    
    // Cancel the interval
    timer = nil
    // Cancel all session tasks
    cancelSessionTaskForM4()
    cancelSessionTaskForM4R()
    cancelSessionTaskForM6()
    cancelSessionTaskForM6R()
  }
  
  ///
  /// Fetch all API data for all active lines in preferences
  ///
  /// - Remark:
  /// It doesn't call API data for the tasks still in progress
  ///
  func fetchApiData () {
    debug.log("Fetch API data")
  
    if m4Active {
      if m4SessionTask == nil {
        debug.log("Fetch A-4-\(m4Station)")
        m4SessionTask = getApiData(forLine: .m4, to: .A) {
          self.cancelSessionTaskForM4()
        }
      }
      
      if m4RSessionTask == nil {
        debug.log("Fetch R-4-\(m4Station)")
        m4RSessionTask = getApiData(forLine: .m4, to: .R) {
          self.cancelSessionTaskForM4R()
        }
      }
    }
    
    if m6Active {
      if m6SessionTask == nil {
        debug.log("Fetch A-6-\(m6Station)")
        m6SessionTask = getApiData(forLine: .m6, to: .A) {
          self.cancelSessionTaskForM6()
        }
      }
      
      if m6RSessionTask == nil {
        debug.log("Fetch R-6-\(m6Station)")
        m6RSessionTask = getApiData(forLine: .m6, to: .R) {
          self.cancelSessionTaskForM6R()
        }
      }
    }
  }
  
  ///
  /// Handle Schedules retrieves from API
  ///
  /// - parameters:
  ///   - line: Line
  ///   - direction: Direction
  ///   - schedules: Schedule array retrieves from API
  ///
  func handleSchedules(for line: RatpLine, to direction: RatpDirection, with schedules: [RatpSchedule]) {
    ratpLinesTable.setHidden(false) // Display the table if it was hidden
    
    guard let row = getTableRow(forLine: line, to: direction) else { return }
    
    let color = RatpColor(line)
    let firstSchedule = schedules[0]

    if schedules.count > 1 {
      let secondSchedule = schedules[1]
      row.secondLabel.setText(secondSchedule.message)
    }
    
    row.lineGroup.setHidden(false)
    row.firstLabel.setText(firstSchedule.message)
    row.titleLabel.setText(firstSchedule.destination)
    row.lineImageTitle.setText("\(line.rawValue)")
    row.lineGroup.setBackgroundColor(color.getUIColor())
  }
  
  ///
  /// Handle API error before handle schedules
  ///
  /// - parameters:
  ///   - schedules: Schedule array retrieves from API or nil on error
  ///   - line: Line
  ///   - direction: Direction
  ///   - error: API Error or nil
  ///
  /// - SeeAlso: `handleSchedules(for:to:with:)`
  ///
  func handleFetchData(_ schedules: [RatpSchedule]?, line: RatpLine, to direction: RatpDirection, error: Error?) {
    if error != nil {
      debug.log(error!)

      return
    }

    guard let schedules = schedules else { return }
    
    handleSchedules(for: line, to: direction, with: schedules)
  }
  
  ///
  /// Get the API data for the line and direction
  ///
  /// - parameters:
  ///   - line: The line
  ///   - direction: The direction
  ///   - then: Closure called when request ends
  ///
  /// - returns:
  /// Session Task for this HTTP Request
  ///
  func getApiData(
    forLine line: RatpLine,
    to direction: RatpDirection,
    then: @escaping () -> Void
  ) -> URLSessionTask {
    var station = ""
    
    switch line {
    case .m4:
      station = preferences.stationM4
    case .m6:
      station = preferences.stationM6
    }
    
    return api.schedules(forLine: line, to: direction, forStation: station) { schedules, error in
      then()
      
      self.debug.log("Fetch \(direction.rawValue)-\(line.rawValue) : done")
      
      self.handleFetchData(schedules, line: line, to: direction, error: error)
    }
  }
  
  ///
  /// Start an interval timer to fetch all API data
  ///
  func startTimer() {
    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
      self.fetchApiData() // After self.interval has passed, call API
    })
  }
  
  ///
  /// Get the rowController in the WKInterfaceTable for the line and direction
  ///
  /// - parameters:
  ///   - line: The line
  ///   - direction: The direction
  ///
  /// - returns:
  /// Optional(LineRowType)
  ///
  func getTableRow(forLine line: RatpLine, to direction: RatpDirection) -> LineRowType? {
    var index = 0
    
    switch ratpLinesTable.numberOfRows { // The rowController index changes from the number of rows in the table
    case 2:
      if direction == .A {
        index = 0
      } else {
        index = 1
      }
    case 0:
      return nil
    default:
      if m4Active && line == .m4 && direction == .A {
        index = 0
      } else if m4Active && line == .m4 && direction == .R {
        index = 1
      } else if m6Active && line == .m6 && direction == .A {
        index = 2
      } else {
        index = ratpLinesTable.numberOfRows - 1
      }
    }
    
    return ratpLinesTable.rowController(at: index) as? LineRowType
  }
  
  ///
  /// Cancel the API Session Task
  ///
  func cancelSessionTaskForM4() {
    m4SessionTask = nil
  }
  
  ///
  /// Cancel the API Session Task
  ///
  func cancelSessionTaskForM6() {
    m6SessionTask = nil
  }
  
  ///
  /// Cancel the API Session Task
  ///
  func cancelSessionTaskForM4R() {
    m4RSessionTask = nil
  }
  
  ///
  /// Cancel the API Session Task
  ///
  func cancelSessionTaskForM6R() {
    m6RSessionTask = nil
  }
  
  ///
  /// Reset the table
  ///
  /// - SeeAlso: `self.numberOfActiveLines`
  ///
  func resetTable() {
    let linesToDelete = IndexSet(Array(0...ratpLinesTable.numberOfRows))
    ratpLinesTable.removeRows(at: linesToDelete)
    
    lastM4Station = m4Station
    lastM6Station = m6Station
    
    ratpLinesTable.setHidden(true)
    ratpLinesTable.setNumberOfRows(numberOfActiveLines, withRowType: "LineRowType")
  }
  
  ///
  /// Hide or display the noLineSelected text if no lines are active
  ///
  func handleNoLineSelected() {
    if !m4Active && !m6Active {
      noLineSelectedGroup.setHidden(false)
    } else {
      noLineSelectedGroup.setHidden(true) // Display no line label if no line is selected in options
    }
  }
}
