//
//  LocationManager.swift
//  Quickerala
//
//  Created by Bibin on 23/09/19.
//  Copyright © 2019 Bibin. All rights reserved.
//

import UIKit
import CoreLocation

/// fetching Location
/// handle permission
/// return object with string, coordinates, string
/// Use Google Location services to reverse geocode location
/// or use google API to get closest location

final class Location: Codable {
    let placeName: String
    let coordinate: Coordinate
    
    static var current: Location? {
        get { return UserDefaults.standard.currentLocation }
        set { UserDefaults.standard.currentLocation = newValue }
    }
    
    static var permissionStatus: CLAuthorizationStatus { return CLLocationManager.authorizationStatus() }
    
    init(with coordinate: Coordinate, placeName: String) {
        self.coordinate = coordinate
        self.placeName = placeName
    }
    
    static func fetch(completion: ((Location?) -> Void)?) {
        LocationManager.common.request { completion?($0) }
    }
    
}

final private class LocationManager: NSObject {
    
    private lazy var locationManger: CLLocationManager? = .init()
    private var completion: ((Location?) -> Void)?
    
    private static let _common: LocationManager = .init()
    static var common: LocationManager { return _common }
    
    private override init() {}
    func request(completion: ((Location?) -> Void)?) {
        self.locationManger = self.locationManger ?? .init()
        self.locationManger?.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .restricted, .denied:
            let message = Bundle.main.applicationName + " does not have access to your Location. To enable access, tap Settings ‣ Location"
            UIViewController.top?.alert(with: "Permission denied",
                                        message: message,
                                        primaryActionTitle: "Settings",
                                        primaryAction: { URL(string: UIApplication.openSettingsURLString)?.open() },
                                        secondaryActionTitle: "Dismiss")
            completion?(nil)
        case .notDetermined:
            self.completion = completion
            self.locationManger?.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            self.completion = completion
            Log.debug("Location Authorized. Initiating location fetch.")
            self.locationManger?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManger?.requestLocation()
        @unknown default: completion?(nil)
            
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard  status != .notDetermined else { return }
        
        guard [.authorizedWhenInUse, .authorizedAlways].contains(status) else {
            completion?(nil)
            Log.error("Location Permisiion Denied. Fetch terminated.")
            return
        }
        Log.debug("Location Authorized. Initiating location fetch.")
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first//?.coordinate
        Log.debug("Fetched Location. Coordinates: \(String(describing: location?.coordinate))")
        guard location != nil else { self.completion?(nil); return }
        self.reverseGeocode(location!) { (placeName) in
            guard placeName != nil else { self.completion?(nil); return }
            let location = Location.init(with: location!.coordinate.coordinate, placeName: placeName!)
            Location.current = location
            self.completion?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil)
    }
}

private extension LocationManager {
    func reverseGeocode(_ location: CLLocation, completion: @escaping (String?) -> Void) {
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil else {
                Log.error(String(describing: error?.localizedDescription))
                completion(nil)
                return
            }
            let placeName = placemarks?.first?.locality ?? placemarks?.first?.subLocality ?? placemarks?.first?.administrativeArea
            Log.debug("Reverse Geocode Success. \(String(describing: placeName))")
            completion(placeName)
        }
    }
}

struct Coordinate: Codable, Hashable {
    let latitude, longitude: Double
}

extension Coordinate {
    var clCoordinate: CLLocationCoordinate2D {
        return .init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    var coordinate: Coordinate { return .init(latitude: latitude, longitude: longitude) }
}
