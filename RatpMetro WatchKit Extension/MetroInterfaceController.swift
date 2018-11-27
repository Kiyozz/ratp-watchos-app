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
    @IBOutlet weak var m4FirstLabel: WKInterfaceLabel!
    @IBOutlet weak var m4SecondLabel: WKInterfaceLabel!
    @IBOutlet weak var m6FirstLabel: WKInterfaceLabel!
    @IBOutlet weak var m6SecondLabel: WKInterfaceLabel!
    
    var timer: Timer? = nil {
        willSet {
            print("invalide")
            timer?.invalidate()
        }
    }

    let interval : TimeInterval = 3.0
    var currentFetchTask: URLSessionTask? {
        willSet {
            currentFetchTask?.cancel()
        }
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        super.willActivate()
        
        print("WillActivate")

        callFetch(nil)
        startTimer()
    }

    override func willDisappear() {
        super.willDisappear()
        
        print("Disappear")

        timer = nil

        taskDone()
    }
    
    func startTimer() {
        if let _ = timer {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: callFetch)
    }
    
    func callFetch (_: Timer?) -> Void {
        if let _ = currentFetchTask {
            return
        }
        
        print("Fetch called")
        
        currentFetchTask = Fetch.get(url: "https://my-json-server.typicode.com/Kiyozz/json-fake-api/lines", handler: fetchLinesHandler)
    }
    
    func fetchLinesHandler (data: Data?, urlResponse: URLResponse?, error: Error?) -> Void {
        taskDone()
        
        if let error = error {
            print("Error occured during fetch metro lines \(error.localizedDescription)")
        }
        
        guard let data = data else { return }
        
        let decoder = JsonDecodeWrapper()

        let payload = decoder.decode(type: MetroLinesPayload.self, from: data)
        
        guard let payloadUnwrapped = payload else { return }
        
        guard let m4 = payloadUnwrapped.M4 else { return }
        guard let m6 = payloadUnwrapped.M6 else { return }
        
        m4FirstLabel.setText("\(m4.first!) min")
        m4SecondLabel.setText("\(m4[1]) min")
        m6FirstLabel.setText("\(m6.first!) min")
        m6SecondLabel.setText("\(m6[1]) min")
    }
    
    func taskDone() {
        currentFetchTask = nil
    }
}
