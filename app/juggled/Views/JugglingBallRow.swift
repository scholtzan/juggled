import Foundation
import SwiftUI

struct JugglingBallRow: View {
    var jugglingBall: JugglingBall

    var body: some View {
        HStack {
            HStack {
                Text(jugglingBall.displayName)
                    .bold()
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                gradient: .init(colors: jugglingBall.colorsUsed()),
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


struct JugglingBallRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            JugglingBallRow(jugglingBall: JugglingBall(deviceName: "Juggling Ball", displayName: "Juggling Ball", routine: Routine()))
        }
    }
}
