import Foundation
import SwiftUI

struct JugglingBallView: View {
    @Binding var jugglingBall: JugglingBall
    @Binding var savedRoutines: [Routine]
    
    @State private var showRoutineStepPopup = false
    @State private var routineStepEditing: Int = 0
    
    @State private var showRoutinePalette = false
    
    var body: some View {
        VStack {
            Text(self.jugglingBall.deviceName).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
             // todo
//            HStack {
//                Text("Throws: ")
//                Text("Catches: ")
//                Text("Todo stats: ")
//            }
            
            HStack {
                Spacer()
                Button(action: {
                    self.showRoutinePalette = true
                }) {
                    HStack {
                        Image(systemName: "paintpalette.fill")
                            .font(.body)
                    }
                }
                .padding(10)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.entryBackground)
                                .shadow(color: Color.entryShadow, radius: 1, x: 0, y: 2))
                .clipShape(Capsule())
                .popover(isPresented: $showRoutinePalette, content: {
                    Text("Select routine")
                    VStack(alignment: .leading) {
                        ScrollView {
                            ForEach(savedRoutines, id: \.id) { routine in
                                Button(action: {
                                    self.jugglingBall.routine = Routine(steps: routine.steps)
                                    self.showRoutinePalette = false
                                }) {
                                    RoutineRow(routine: routine, routines: $savedRoutines, deletable: false).padding(.top, 50)
                                }
                            }.padding(.top, 50)
                        }
                    }
                })
                
                Menu(content: {
                    Button {
                        savedRoutines.append(self.jugglingBall.routine)
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }, label: {
                    Image(systemName: "ellipsis.circle.fill")
                })
                .padding(10)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.entryBackground)
                                .shadow(color: Color.entryShadow, radius: 1, x: 0, y: 2))
                .clipShape(Capsule())
            }
            
            RoutineView(routine: $jugglingBall.routine, savedRoutines: $savedRoutines)
            Spacer()

        }
    }
    
    private func binding(for routineStep: RoutineStep) -> Binding<RoutineStep> {
        guard let index = jugglingBall.routine.steps.firstIndex(where: { $0 == routineStep }) else {
            fatalError("Can't find connected routine step")
        }
        return $jugglingBall.routine.steps[index]
    }
}

struct JugglingBallView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JugglingBallView(jugglingBall: .constant(JugglingBall(deviceName: "Ball", displayName: "Ball", routine: Routine()))!, savedRoutines: .constant([]))
        }
    }
}
