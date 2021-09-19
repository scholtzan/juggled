import SwiftUI

enum RoutineAction: String, CaseIterable, Codable {
    case Caught
    case Thrown
    case SetColor
    case Wait
}

struct RoutineStep: Hashable, Identifiable, Codable {
    var id = UUID()
    var led1: Color = Color(.black)
    var led2: Color = Color(.black)
    var action: RoutineAction = RoutineAction.SetColor
    var arg: String = ""
}

struct Routine: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String? = nil
    var steps: [RoutineStep] = []
    
    func colorsUsed() -> [Color] {
        var colors: [Color] = []
        let setColorSteps = steps.filter({ $0.action == RoutineAction.SetColor })
        for step in setColorSteps {
            colors.append(adjustColorDisplay(color: step.led1))
            colors.append(adjustColorDisplay(color: step.led2))
        }
        
        if colors.isEmpty {
            colors = [Color.entryBackground]
        }
        
        return colors
    }
}
