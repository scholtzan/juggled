import SwiftUI

struct JugglingBall: Hashable {
    let id = UUID()
    var deviceName: String
    var displayName: String
    var routine: Routine
    
    func message() -> String {
        var message = "set;"
                
        for (index, step) in routine.steps.enumerated() {
            if index > 0 {
                message += "|"
            }
            
            message += step.action.rawValue.lowercased()
            
            if step.action == RoutineAction.Wait {
                message += ";" + step.arg + ";0,0,0;0,0,0"
            } else if step.action == RoutineAction.SetColor {
                message += ";;"
                message += String(Int(step.led1.components.red)) + ","
                message += String(Int(step.led1.components.green)) + ","
                message += String(Int(step.led1.components.blue))
                
                message += ";"
                message += String(Int(step.led2.components.red)) + ","
                message += String(Int(step.led2.components.green)) + ","
                message += String(Int(step.led2.components.blue))
            } else {
                message += ";;0,0,0;0,0,0"
            }
        }
        
        print(message)
        return message
    }
    
    func colorsUsed() -> [Color] {
        return routine.colorsUsed()
    }
}
