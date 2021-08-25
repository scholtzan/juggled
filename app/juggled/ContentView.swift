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
                        .background(Color.gray)
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
        }
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
