//
//  JugglingBallRowView.swift
//  juggled
//
//  Created by Anna Scholtz on 2021-08-15.
//  Copyright © 2021 Anna Scholtz. All rights reserved.
//

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
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(height: (5.0))
        }
    }
}


struct JugglingBallRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            JugglingBallRow(jugglingBall: JugglingBall(deviceName: "Juggling Ball", displayName: "Juggling Ball", routine: [RoutineStep(led1: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), led2: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), action: RoutineAction.SetColor, arg: nil)]))
        }
    }
}
