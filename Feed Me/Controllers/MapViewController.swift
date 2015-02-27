//
//  MapViewController.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, TypesTableViewControllerDelegate , CLLocationManagerDelegate , GMSMapViewDelegate
{
  

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]

    let locationManager = CLLocationManager()
  
    let dataProvider = GoogleDataProvider()

    var randomLineColor: UIColor {
      get {
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
      }
    }
  
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
      // 1
      let googleMarker = mapView.selectedMarker as PlaceMarker
    
      // 2
      dataProvider.fetchDirectionsFrom(mapView.myLocation.coordinate, to: googleMarker.place.coordinate) {optionalRoute in
        if let encodedRoute = optionalRoute {
          // 3
          let path = GMSPath(fromEncodedPath: encodedRoute)
          let line = GMSPolyline(path: path)
        
          // 4
          line.strokeWidth = 4.0
          line.strokeColor = self.randomLineColor
          line.tappable = true
          line.map = self.mapView
        
          // 5
          mapView.selectedMarker = nil
        }
      }
    }
  
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
      mapCenterPinImage.fadeIn(0.25)
      mapView.selectedMarker = nil
      return false
    }
  
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
      mapCenterPinImage.fadeOut(0.25)
      return false
    }
  
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView! {
      // 1
      let placeMarker = marker as PlaceMarker
    
      // 2
      if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView {
        // 3
        infoView.nameLabel.text = placeMarker.place.name
      
        // 4
        if let photo = placeMarker.place.photo {
              infoView.placePhoto.image = photo
          } else {
          infoView.placePhoto.image = UIImage(named: "generic")
        }
      
        return infoView
      }
      else {
        return nil
      }
    }
  
    @IBAction func refreshPlaces(sender: AnyObject) {
        fetchNearbyPlaces(mapView.camera.target)
    }
    
    var mapRadius: Double {
        get {
            let region = mapView.projection.visibleRegion()
            let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
            let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
            return max(horizontalDistance, verticalDistance)*0.5
        }
    }
  
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
      // 1
      mapView.clear()
      // 2
      dataProvider.fetchPlacesNearCoordinate(coordinate, radius:mapRadius, types: searchedTypes) { places in
        for place: GooglePlace in places {
          // 3
          let marker = PlaceMarker(place: place)
          // 4
          marker.map = self.mapView
        }
      }
    }
  

    func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
        addressLabel.lock()
        if (gesture) {
          mapCenterPinImage.fadeIn(0.25)
          mapView.selectedMarker = nil
        }
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
            //Add this line
            self.addressLabel.unlock()
            if let address = response?.firstResult() {
                
                // 3
                let lines = address.lines as [String]
                self.addressLabel.text = join("\n", lines)
                // 1
                let labelHeight = self.addressLabel.intrinsicContentSize().height
                self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
                // 4
                UIView.animateWithDuration(0.25) {
                    //2
                    self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        reverseGeocodeCoordinate(position.target)
    }
    
    // 1
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 2
        if status == .AuthorizedWhenInUse {
            
            // 3
            locationManager.startUpdatingLocation()
            
            //4
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    // 5
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
            
            // 6
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            // 7
            locationManager.stopUpdatingLocation()
        }
    }

    
    @IBAction func mapTypeSegmentPressed(sender: AnyObject) {
        let segmentedControl = sender as UISegmentedControl
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = kGMSTypeNormal
        case 1:
            mapView.mapType = kGMSTypeSatellite
        case 2:
            mapView.mapType = kGMSTypeHybrid
        default:
            mapView.mapType = mapView.mapType
        }
    }
    
   override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    mapView.delegate = self
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as UINavigationController
      let controller = segue.destinationViewController.topViewController as TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
  }
  
  // MARK: - Types Controller Delegate
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = sorted(controller.selectedTypes)
    dismissViewControllerAnimated(true, completion: nil)
  }
}

