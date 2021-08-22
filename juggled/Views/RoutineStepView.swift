import Foundation
import SwiftUI

struct RoutineStepView: View {
    @Binding var routineStep: RoutineStep
    @Binding var showPopup: Bool
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("Event Type", selection: $routineStep.action) {
                        ForEach(RoutineAction.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                }
                
                if (self.routineStep.action == RoutineAction.SetColor) {
                    Section {
                        ColorPicker("LED 1 Color", selection: $routineStep.led1)
                        ColorPicker("LED 2 Color", selection: $routineStep.led2)
                    }
                } else if (self.routineStep.action == RoutineAction.Wait) {
                    Section {
                        HStack {
                            Text("Duration [ms]: ")
                            TextField("", text: $routineStep.arg).keyboardType(.numberPad)
                        }
                    }
                }

            }
            
            Spacer()
        }
        .navigationBarTitle("Step Configuration")
        .navigationBarItems(trailing: Button("Save", action: {
            self.showPopup = false
        }))
    }
}

struct RoutineStepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoutineStepView(routineStep: .constant(RoutineStep(led1: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), led2: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), action: RoutineAction.SetColor, arg: ""))!, showPopup: .constant(true))
        }
    }
}
