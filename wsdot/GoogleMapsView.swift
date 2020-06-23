//
//  GoogleMapView.swift
//  WSDOT
//
//  Created by Logan Sims on 6/22/20.
//  Copyright © 2020 WSDOT. All rights reserved.
//

import SwiftUI
import GoogleMaps

@available(iOS 13.0.0, *)
struct GoogleMapsView: UIViewRepresentable {
    
    var zoom: Float = 15.0
    var latitude: Double = -33.86
    var longitude: Double = 151.20
    
    init(zoom: Float, latitude: Double, longitude: Double) {
        self.zoom = zoom
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func makeUIView(context: Self.Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoom)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isTrafficEnabled = true
   
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        print("HERE")
        let marker : GMSMarker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: longitude, longitude: longitude)
        marker.icon = UIImage(named: "icMapAlertLow")
        marker.map = mapView
        
    }
}

@available(iOS 13.0.0, *)
struct GoogleMapsView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleMapsView(zoom: 15, latitude: -33, longitude: 151)
    }
}
