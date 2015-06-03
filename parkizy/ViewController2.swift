

import UIKit
import MapKit
import CoreLocation
import Parse

class ViewController2:  UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var manager:CLLocationManager!
    var myLocations: [CLLocation] = []
    override func viewDidLoad()
    {
        
        super.viewDidLoad()

        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        
        //Setup our Map View
        mapView.delegate = self
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
        
        var query = PFQuery(className:"Emplacements")
        query.whereKey("availability", equalTo:true)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
          var descLocation: PFGeoPoint = PFGeoPoint()
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        if object["availability"]! as! NSObject == 1
                        {
                        descLocation = object["GeoPoint"] as! PFGeoPoint
                        let location = CLLocationCoordinate2D(
                            latitude: descLocation.latitude,
                            longitude: descLocation.longitude
                        )
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location
                        self.mapView.addAnnotation(annotation)
                        }
                    }
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        myLocations.append(locations[0] as! CLLocation)
        
        let spanX = 0.007
        let spanY = 0.007
        var newRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(spanX, spanY))
        mapView.setRegion(newRegion, animated: true)
        
        if (myLocations.count > 1){
            var sourceIndex = myLocations.count - 1
            var destinationIndex = myLocations.count - 2
            
            let c1 = myLocations[sourceIndex].coordinate
            let c2 = myLocations[destinationIndex].coordinate
            var a = [c1, c2]
            var polyline = MKPolyline(coordinates: &a, count: a.count)
            //mapView.addOverlay(polyline)
        }
    }
    
}

