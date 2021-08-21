import Foundation
import SwiftUI

struct RoutineStepView: View {
    @Binding var routineStep: RoutineStep
    @State var selectedEventType = "Wait"
    let eventTypes = ["Set Color", "Thrown", "Caught", "Wait"]
    @State var led1Color: Color = Color(red: 0, green: 0, blue: 0)
    @State var led2Color: Color = Color(red: 0, green: 0, blue: 0)
    @State var duration: String = ""
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("Event Type", selection: $selectedEventType) {
                        ForEach(eventTypes, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                if (self.selectedEventType == "Set Color") {
                    Section {
                        ColorPicker("LED 1 Color", selection: $led1Color)
                        ColorPicker("LED 2 Color", selection: $led2Color)
                    }
                } else if (self.selectedEventType == "Wait") {
                    Section {
                        HStack {
                            Text("Duration [ms]: ")
                            TextField("", text: $duration).keyboardType(.numberPad)
                        }
                    }
                }

            }
            
            Spacer()
        }
    }
}

struct RoutineStepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoutineStepView(routineStep: .constant(RoutineStep(led1: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), led2: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), action: RoutineAction.SetColor, arg: nil))!)
        }
    }
}
