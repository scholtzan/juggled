import Foundation
import SwiftUI

struct RoutineView: View {
    @Binding var routine: Routine
    @Binding var savedRoutines: [Routine]
    
    @State private var showRoutineStepPopup = false
    @State private var routineStepEditing: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 50) {
                ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, routineStep in
                    Button(action: {
                        self.routineStepEditing = index
                        self.showRoutineStepPopup = true
                    }) {
                        RoutineStepRow(routineStep: routineStep, steps: $routine.steps)
                    }
                }
                 
                Button(action: {
                    self.routine.steps.append(RoutineStep())
                    self.routineStepEditing = self.routine.steps.endIndex - 1
                    self.showRoutineStepPopup = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.body)
                        Text("Add Step")
                    }
                }
                .padding(10)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.entryBackground)
                                .shadow(color: Color.entryShadow, radius: 1, x: 0, y: 2))
                .clipShape(Capsule())
                .popover(isPresented: $showRoutineStepPopup, content: {
                    NavigationView {
                        RoutineStepView(routineStep: $routine.steps[self.routineStepEditing], showPopup: $showRoutineStepPopup)
                    }
                })
            }.padding(.top, 50)
        }
    }
}

struct RoutineView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RoutineView(routine: .constant(Routine()), savedRoutines: .constant([]))
        }
    }
}
