//
//  ContentView.swift
//  juggled
//
//  Created by Anna Scholtz on 2021-08-09.
//  Copyright © 2021 Anna Scholtz. All rights reserved.
//

import SwiftUI
import CoreBluetooth



enum RoutineAction: String, CaseIterable {
    case Caught
    case Thrown
    case SetColor
    case Wait
}

struct RoutineStep: Hashable {
    let id = UUID()
    var led1: Color = Color(.black)
    var led2: Color = Color(.black)
    var action: RoutineAction = RoutineAction.SetColor
    var arg: String = ""
}

struct JugglingBall: Hashable {
    let id = UUID()
    var deviceName: String
    var displayName: String
    var routine: [RoutineStep]
    
    func message() -> String {
        var message = "set;"
                
        for (index, step) in routine.enumerated() {
            if index > 0 {
                message += "|"
            }
            
            message += step.action.rawValue.lowercased()
            
            if step.action == RoutineAction.Wait {
                message += ";" + step.arg + ";0,0,0;0,0,0"
            } else if step.action == RoutineAction.SetColor {
                message += ";;"
                message += String(Int(step.led1.components.red)) + ","
                message += String(Int(step.led1.components.green)) + ","
                message += String(Int(step.led1.components.blue))
                
                message += ";"
                message += String(Int(step.led2.components.red)) + ","
                message += String(Int(step.led2.components.green)) + ","
                message += String(Int(step.led2.components.blue))
            } else {
                message += ";;0,0,0;0,0,0"
            }
        }
        
        print(message)
        return message
    }
    
    func colorsUsed() -> [Color] {
        var colors: [Color] = []
        let setColorSteps = routine.filter({ $0.action == RoutineAction.SetColor })
        for step in setColorSteps {
            colors.append(adjustColorDisplay(color: step.led1))
            colors.append(adjustColorDisplay(color: step.led2))
        }
        
        if colors.isEmpty {
            colors = [Color.entryBackground]
        }
        
        return colors
    }
}

func adjustColorDisplay(color: Color) -> Color {
    if color.components.red < 20 && color.components.blue < 20 && color.components.green < 20 {
        return Color.entryBackground
    } else {
        return color
    }
}

struct ContentView: View {
    @ObservedObject var bleConnection = BleConnection()
    @State var isDevicePopoverShown = false
    @State var connectingDevices: [Device] = []
    @State var connectedJugglingBalls: [JugglingBall] = []
    
    var body: some View {
        TabView {
            NavigationView {
                VStack(alignment: .leading) {
                    ScrollView {
                        ForEach(connectedJugglingBalls, id: \.id) { jugglingBall in
                            NavigationLink(destination: JugglingBallView(jugglingBall: binding(for: jugglingBall))) {
                                JugglingBallRow(jugglingBall: jugglingBall)
                            }
                            .padding(.top, 50)
                        }
                    }
                }
                    .navigationTitle("Juggling Balls")
                    .navigationBarItems(trailing:
                        Button(action: {
                            self.isDevicePopoverShown = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.body)
                            }
                        }
                        .padding(10)
                        .foregroundColor(.white)
                        .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.entryBackground)
                                        .shadow(color: Color.entryShadow, radius: 1, x: 0, y: 2))
                        .clipShape(Capsule())
                        .popover(isPresented: $isDevicePopoverShown) {
                            Text("Connect to ...")
                            List(self.bleConnection.scannedDevices, id: \.self) { device in
                                Button(action: {
                                    self.connectingDevices.append(device)
                                    bleConnection.connectDevice(device: device)
                                    self.connectingDevices = self.connectingDevices.filter({$0 != device})
                                    self.isDevicePopoverShown = false

                                    // todo: error handling
                                    self.connectedJugglingBalls.append(JugglingBall(deviceName: device.name, displayName: device.name, routine: []))
                                }) {
                                    HStack {
                                        Text(device.name)
                                        Spacer()
                                        ProgressView().isHidden(!self.connectingDevices.contains(device))
                                    }
                                }
                            }
                        }
                )
            }.navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
            }
            Text("Saved")
                .tabItem {
                    Image(systemName: "paintpalette.fill")
                    Text("Saved")
            }
            Text("Compositions")
                .tabItem {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Compositions")
            }
            Text("Settings")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
            }
        }.onChange(of: connectedJugglingBalls, perform: { [connectedJugglingBalls] value in
            let changed = connectedJugglingBalls.first(where: {!value.contains($0)})
            
            if changed != nil {
                if !changed!.routine.isEmpty {
                    bleConnection.sendMessage(deviceName: changed!.deviceName, message: changed!.message())
                }
            }
        })
    }
    
    private func binding(for jugglingBall: JugglingBall) -> Binding<JugglingBall> {
        guard let index = connectedJugglingBalls.firstIndex(where: { $0.deviceName == jugglingBall.deviceName }) else {
            fatalError("Can't find connected juggling ball")
        }
        return $connectedJugglingBalls[index]
    }
}

extension View {
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
