import Foundation
import SwiftUI


struct RoutineRow: View {
    var routine: Routine
    @Binding var routines: [Routine]
    var deletable = true

    var body: some View {
        HStack {
            HStack {
                if routine.name != nil {
                    Text(routine.name!)
                        .bold()
                } else {
                    Text(routine.id.uuidString)
                }
                Spacer()
                if deletable {
                    Button(action: {
                        routines.remove(at: routines.firstIndex(of: routine)!)
                    }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                                .font(.body)
                        }
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                gradient: .init(colors: routine.colorsUsed()),
                                startPoint: .init(x: 0, y: 0),
                                endPoint: .init(x: 1, y: 0)
                              ))
                            .shadow(color: Color.entryShadow, radius: 1, x: 0, y: 2))
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(height: (5.0))
        }
    }
}


struct RoutineRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoutineRow(routine: Routine(), routines: .constant([]))
        }
    }
}
