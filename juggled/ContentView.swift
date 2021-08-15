//
//  ContentView.swift
//  juggled
//
//  Created by Anna Scholtz on 2021-08-09.
//  Copyright © 2021 Anna Scholtz. All rights reserved.
//

import SwiftUI
import CoreBluetooth

struct JugglingBall: Hashable {
    var device: Device
    var displayName: String
}

struct ContentView: View {
    @ObservedObject var bleConnection = BleConnection()
    @State var isDevicePopoverShown = false
    @State var connectingDevices: [Device] = []
    @State var connectedJugglingBalls: [JugglingBall] = []
    
    
    var body: some View {
        TabView {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("Juggling Balls")
                        .font(.largeTitle)
                    Spacer()
                    Button(action: {
                        self.isDevicePopoverShown = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .font(.headline)
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
                                self.connectedJugglingBalls.append(JugglingBall(device: device, displayName: device.name))
                            }) {
                                HStack {
                                    Text(device.name)
                                    Spacer()
                                    ProgressView().isHidden(!self.connectingDevices.contains(device))
                                }
                            }
                        }
                    }
                }
                Spacer()
                List(self.connectedJugglingBalls, id: \.self) { jugglingBall in
                    Text(jugglingBall.displayName)
                }
            }
            .padding()
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
