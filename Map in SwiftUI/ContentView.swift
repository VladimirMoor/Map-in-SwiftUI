//
//  ContentView.swift
//  Map in SwiftUI
//
//  Created by Vladimir on 08.07.2021.
//

import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 13.086, longitude: 80.2769), span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 180))
    @State private var tracking: MapUserTrackingMode = .follow
    @State private var manager = CLLocationManager()
    @StateObject private var managerDelegate = LocationDelegate()
    @State private var squarePins: [MeetPoint] = []
    @State private var showPinAnnotation = false

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: squarePins) { pin in
                
                MapAnnotation(coordinate: pin.coordinate, anchorPoint: CGPoint(x: 0.5, y: 0.5)) {
                    VStack {
                        if showPinAnnotation {
                        Text("\(pin.coordinate.latitude)")
                            .onTapGesture {
                                print("make some func!")
                            }
                        }
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .onTapGesture {
                            showPinAnnotation.toggle()
                        }
                    }
                }
                
            }
            
            Circle()
                .fill(Color.blue)
                .opacity(0.3)
                .frame(width: 30, height: 30)
            Image(systemName: "plus")
                .resizable()
                .opacity(0.4)
                .frame(width: 10, height: 10)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Save") {
                        print("\(region.center)")
                        squarePins.append(MeetPoint(coordinate: region.center))
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Circle())
                    .padding(.bottom, 40)
                    .padding(.trailing, 30)
                }
            }

        }
        .onAppear() {
            manager.delegate = managerDelegate
        }
    }
}

class LocationDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var pins: [Pin] = []
    
    // checking authorisation status
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        // we are going to use in case "When in use" only
        
        if manager.authorizationStatus == .authorizedWhenInUse {
                print("authorised")
            
            // setting reduced accuracy in false
            // and updating location
            
            manager.startUpdatingLocation()
            
        } else {
            print("not authorised")
            
            // request to access "When in use"
            manager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        pins.append(Pin(location: locations.last!))
    }
}

struct Pin: Identifiable {
    var id = UUID()
    var location: CLLocation
}

struct MeetPoint: Identifiable {
    var id = UUID()
    var coordinate: CLLocationCoordinate2D
}
