//
//  CalibrationModel.Swift
//  Cyclify
//
//  Created by Carolyn Yang on 3/28/25.
//

import Foundation

enum CalibrationStep: String, CaseIterable {
    case leanLeft = "Lean Left"
    case leanRight = "Lean Right"
    case leanForward = "LeanForward"
    case leanBackward = "LeanBackward"
}

class CalibrationModel: ObservableObject {
    @Published var forceReadings: [CalibrationStep: [[Int]]] = [:]
    
    init() {
        CalibrationStep.allCases.forEach {step in
            forceReadings[step] = []
        }
    }
    
    func addReadings(for step: CalibrationStep, readings: [Int]) {
            forceReadings[step]?.append(readings)
            objectWillChange.send() // Ensure the UI updates
        }
    
    func resetReadings(for step: CalibrationStep) {
        forceReadings[step] = []
        objectWillChange.send()
    }

    func getReadings(for step: CalibrationStep) -> [[Int]] {
        return forceReadings[step] ?? []
    }
    
}
