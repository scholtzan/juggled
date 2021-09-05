//
//  JugglingBallView.swift
//  juggled
//
//  Created by Anna Scholtz on 2021-08-15.
//  Copyright © 2021 Anna Scholtz. All rights reserved.
//

import Foundation
import SwiftUI

struct JugglingBallView: View {
    @Binding var jugglingBall: JugglingBall
    @State private var showRoutineStepPopup = false
    @State private var routineStepEditing: Int = 0
    
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
                    print("Show pallette")
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
                
                Button(action: {
                    print("more")
                }) {
                    HStack {
                        Image(systemName: "ellipsis.circle.fill")
                            .font(.body)
                    }
                }
                .padding(10)
                .foregroundColor(.white)
                .background(RoundedRectangle(cornerRadius: 10)
                                .fill(Color.entryBackground)
                                .shadow(color: Color.entryShadow, radius: 1, x: 0, y: 2))
                .clipShape(Capsule())
            }
        
            
            ScrollView {
                VStack(spacing: 50) {
                    ForEach(Array(jugglingBall.routine.enumerated()), id: \.offset) { index, routineStep in
                        Button(action: {
                            self.routineStepEditing = index
                            print(self.routineStepEditing)
                            self.showRoutineStepPopup = true
                        }) {
                            RoutineStepRow(routineStep: routineStep, steps: $jugglingBall.routine)
                        }
                    }
                     
                    Button(action: {
                        self.jugglingBall.routine.append(RoutineStep())
                        self.routineStepEditing = self.jugglingBall.routine.endIndex - 1
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
                            RoutineStepView(routineStep: $jugglingBall.routine[self.routineStepEditing], showPopup: $showRoutineStepPopup)
                        }
                    })
                }.padding(.top, 50)
            }
            Spacer()

        }
    }
    
    private func binding(for routineStep: RoutineStep) -> Binding<RoutineStep> {
        guard let index = jugglingBall.routine.firstIndex(where: { $0 == routineStep }) else {
            fatalError("Can't find connected routine step")
        }
        return $jugglingBall.routine[index]
    }
}

struct JugglingBallView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JugglingBallView(jugglingBall: .constant(JugglingBall(deviceName: "Ball", displayName: "Ball", routine: [RoutineStep()]))!)
        }
    }
}
