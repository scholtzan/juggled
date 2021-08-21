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
    @State private var isPresented = false
    @State private var showRoutineStepPopup = false
    @State private var lastStep = RoutineStep(led1: Color(red: 0, green: 0, blue: 0, opacity: 1.0), led2: Color(red: 0, green: 0, blue: 0, opacity: 1.0), action: RoutineAction.SetColor, arg: nil)
    
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
                ForEach(jugglingBall.routine, id: \.self) { routineStep in
                    RoutineStepRow(routineStep: routineStep)
                }
                
                Button(action: {
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
                .popover(isPresented: $showRoutineStepPopup) {
                    NavigationView {
                        RoutineStepView(routineStep: $lastStep)
                            
                        .navigationBarTitle("Step Configuration")
                        .navigationBarItems(trailing:
                            Button(action: {
                                self.showRoutineStepPopup = false
                                jugglingBall.routine.append(self.lastStep)
                                print(jugglingBall.routine)
//                                self.lastStep = RoutineStep(led1: Color(red: 0, green: 0, blue: 0, opacity: 1.0), led2: Color(red: 0, green: 0, blue: 0, opacity: 1.0), action: RoutineAction.SetColor, arg: nil)
                            }) {
                                Text("Save")
                            }
                        )
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct JugglingBallView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JugglingBallView(jugglingBall: .constant(JugglingBall(deviceName: "Ball", displayName: "Ball", routine: [RoutineStep(led1: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), led2: Color(red: 200.0, green: 100.0, blue: 300.0, opacity: 1.0), action: RoutineAction.SetColor, arg: nil)]))!)
        }
    }
}
