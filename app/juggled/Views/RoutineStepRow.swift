//
//  ActionStepRow.swift
//  juggled
//
//  Created by Anna Scholtz on 2021-08-15.
//  Copyright © 2021 Anna Scholtz. All rights reserved.
//

import Foundation
import SwiftUI

struct RoutineStepRow: View {
    var routineStep: RoutineStep
    @Binding var steps: [RoutineStep]

    var body: some View {
        switch routineStep.action {
        case RoutineAction.SetColor:
            HStack {
                VStack {
                    Text(routineStep.action.rawValue)
                        .bold()
                    if (routineStep.arg != "") {
                        Text("Duration: " + routineStep.arg).font(.footnote)
                    }
                }
                Spacer()
                Button(action: {
                    steps.remove(at: steps.firstIndex(of: routineStep)!)
                }) {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .font(.body)
                    }
                }
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(height: (5.0))
        default:
            HStack {
                Text(routineStep.action.rawValue)
                    .bold()
                Spacer()
                Button(action: {
                    steps.remove(at: steps.firstIndex(of: routineStep)!)
                }) {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .font(.body)
                    }
                }
            }
            .padding()
            .background(Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .frame(height: (5.0))
        }
    }
}

struct RoutineStepRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RoutineStepRow(routineStep: RoutineStep(led1: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), led2: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), action: RoutineAction.SetColor, arg: ""), steps: .constant([]))
        }
    }
}
