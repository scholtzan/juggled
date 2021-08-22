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
    @State var newStep: RoutineStep = RoutineStep()
    @State private var showRoutineStepPopup = false
    
    var body: some View {
        VStack {
            Text(self.jugglingBall.deviceName).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            HStack {
                Text("Throws: ")
                Text("Catches: ")
                Text("Todo stats: ")
            }
            
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
                .background(Color.gray)
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
                .background(Color.gray)
                .clipShape(Capsule())
            }
        
            
            ScrollView {
                VStack(spacing: 50) {
                    ForEach(jugglingBall.routine, id: \.id) { routineStep in
                        Button(action: {
                            self.showRoutineStepPopup = true
                        }) {
                            RoutineStepRow(routineStep: routineStep)
                        }
                    }
                     
                    Button(action: {
                        self.newStep = RoutineStep()
                        self.jugglingBall.routine.append(newStep)
                        self.showRoutineStepPopup = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.body)
                        }
                    }
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.gray)
                    .clipShape(Capsule())
                    .popover(isPresented: $showRoutineStepPopup, content: {
                        NavigationView {
                            RoutineStepView(routineStep: $jugglingBall.routine[self.jugglingBall.routine.endIndex - 1], showPopup: $showRoutineStepPopup)
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
