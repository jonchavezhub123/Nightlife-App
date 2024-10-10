//
//  MapView.swift
//  Nightlife
//
//  Created by Jhon Chavez on 10/7/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
    @StateObject private var locationManager = LocationManager()
    
    @Binding var region: MKCoordinateRegion
    var visiblebars: [Bar]
    @Binding var selectedBar: Bar?
    
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        
        let openBars = visiblebars.filter { $0.isOpen() }
        
        print("1.) Number of open bars: \(openBars.count)")
        print("Number of total bars: \(visiblebars.count)")
        // Add heat map overlay
        let overlay = HeatMapOverlay(bars: openBars)
       // let overlay = HeatMapOverlay(bars: visiblebars)
        mapView.addOverlay(overlay)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
        
        // Efficiently update annotations
        let zoomLevel = log2(360 * (Double(view.frame.size.width / 256) / view.region.span.longitudeDelta))
        let shouldShowAnnotations = zoomLevel >= 17
        
        print("Current zoom level: \(zoomLevel)")
        
        
        // Get existing annotations
        let existingAnnotations = view.annotations.compactMap { $0 as? BarAnnotation }
        let existingBarIds = Set(existingAnnotations.map { $0.bar.id })
        
        if shouldShowAnnotations {
            print("Showing annotations")
            // Show existing annotations
            for annotation in existingAnnotations {
                view.view(for: annotation)?.isHidden = false
            }
            
            // Add new annotations
            let newBars = visiblebars.filter { !existingBarIds.contains($0.id) }
            let newAnnotations = newBars.map { BarAnnotation(bar: $0) }
            view.addAnnotations(newAnnotations)
            
            // Remove annotations for bars that are no longer visible
            let visibleBarIds = Set(visiblebars.map { $0.id })
            let annotationsToRemove = existingAnnotations.filter { !visibleBarIds.contains($0.bar.id) }
            view.removeAnnotations(annotationsToRemove)
        } else {
            print("Hiding annotations")
            // Hide annotations instead of removing them
            for annotation in existingAnnotations {
                view.view(for: annotation)?.isHidden = true
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        // Overlay rendering for heat map
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let heatMapOverlay = overlay as? HeatMapOverlay {
                // return HeatMapRenderer(overlay: heatMapOverlay, bars: parent.visiblebars)
                let openBars = parent.visiblebars.filter { $0.isOpen() }
                
                print("Number of open bars: \(openBars.count)")
                
                return HeatMapRenderer(overlay: heatMapOverlay, bars: openBars)
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        // Sync the region when it changes
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            parent.region = mapView.region
            
            // Update label visibility based on zoom level
            let zoomLevel = log2(360 * (Double(mapView.frame.size.width / 256) / mapView.region.span.longitudeDelta))
            let minZoomLevelForName: Double = 17
            
            mapView.annotations.forEach { annotation in
                if let customAnnotationView = mapView.view(for: annotation) as? CustomBarAnnotationView {
                    customAnnotationView.setLabelVisibility(visible: zoomLevel >= minZoomLevelForName)
                }
            }
        }
        
        // Customize annotations for zoom-based visibility
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let barAnnotation = annotation as? BarAnnotation else { return nil }
            
            let identifier = "BarAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomBarAnnotationView
            
            if annotationView == nil {
                annotationView = CustomBarAnnotationView(annotation: barAnnotation, reuseIdentifier: identifier)
                annotationView?.setupUI()
            } else {
                annotationView?.annotation = barAnnotation
                annotationView?.updateLabel()
            }
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let barAnnotation = view.annotation as? BarAnnotation {
                        print("MapView: Bar selected - \(barAnnotation.bar.name)")
                        
                        // Always update selectedBar, even if it's the same bar
                        parent.selectedBar = barAnnotation.bar
                        
                        print("MapView: selectedBar updated to \(parent.selectedBar?.name ?? "nil")")
                        
                        // Deselect the annotation immediately to allow for re-selection
                        mapView.deselectAnnotation(barAnnotation, animated: false)
                    }
        }
    }
}

class CustomBarAnnotationView: MKAnnotationView {
    private var labelView: UILabel?
    
    override var annotation: MKAnnotation? {
        didSet {
            updateLabel()
        }
    }

    func setupUI() {
        self.canShowCallout = false
        
        if let barIcon = UIImage(named: "barIcon") {
            let resizedIcon = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40)).image { _ in
                barIcon.draw(in: CGRect(origin: .zero, size: CGSize(width: 40, height: 40)))
            }
            self.image = resizedIcon
        }
        
        createLabel()
    }
    
    private func createLabel() {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        
        self.addSubview(label)
        self.labelView = label
        
        updateLabel()
    }
    
    func updateLabel() {
         guard let barAnnotation = annotation as? BarAnnotation else { return }
         
         labelView?.text = barAnnotation.bar.name
         
         if let label = labelView {
             let labelSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20))
             label.frame = CGRect(x: -labelSize.width / 2, y: 50, width: labelSize.width + 12, height: 20)
         }
         
         self.centerOffset = CGPoint(x: 0, y: -20) // Adjust if needed
     }
     
     func setLabelVisibility(visible: Bool) {
         labelView?.isHidden = !visible
     }
 }

    class BarAnnotation: NSObject, MKAnnotation {
        let bar: Bar
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: bar.latitude, longitude: bar.longitude)
        }
        
        var title: String? {
            bar.name
        }
        
        init(bar: Bar) {
            self.bar = bar
            super.init()
        }
    }

class HeatMapOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    var bars: [Bar]
    
    init(bars: [Bar]) {
        self.bars = bars
        
        var rect = MKMapRect.null
        for bar in bars {
            let point = MKMapPoint(CLLocationCoordinate2D(latitude: bar.latitude, longitude: bar.longitude))
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            rect = rect.union(pointRect)
        }
        self.boundingMapRect = rect
        self.coordinate = rect.origin.coordinate
    }
}

class HeatMapRenderer: MKOverlayRenderer {
    var bars: [Bar]
    
    init(overlay: MKOverlay, bars: [Bar]) {
        self.bars = bars
        super.init(overlay: overlay)
    }
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let rect = self.rect(for: mapRect)
            let adjustedZoomScale = max(zoomScale, 0.10)  // Set a minimum zoomScale

            for bar in bars {
                // Calculate a heat value based on the total number of ratings and the average rating
                
                let popularityWeight = Double(bar.userRatingsTotal ?? 0) // Total number of user ratings
                let qualityWeight = bar.rating ?? 0 // Average rating
                let heatValue = (0.6 * popularityWeight) + (0.4 * qualityWeight * 10) // Adjust quality weight scale if necessary
                
                // Scale the base size based on the calculated heat value
            let baseSize: CGFloat = max(min(1000 / adjustedZoomScale, rect.width / 20), 200) * CGFloat(heatValue / 100) / 5 // Normalize heatValue to appropriate size
                let coordinate = CLLocationCoordinate2D(latitude: bar.latitude, longitude: bar.longitude)
                let point = self.point(for: MKMapPoint(coordinate))

                let circleRect = CGRect(x: point.x - baseSize/2, y: point.y - baseSize/2, width: baseSize, height: baseSize)

                if rect.intersects(circleRect) {
                    let color = getColorForReviews(Int(popularityWeight))
                    drawHeatSpot(in: context, center: point, radius: baseSize/2, color: color)
                }
            }
    }
    
    private func getColorForReviews(_ reviews: Int) -> UIColor {
        // Define the review count boundaries
        // Define the review count boundaries
        let minReviews = 0
        let midReviews = 1000
        let maxReviews = 2000
        
        // Interpolate between yellow and orange (0 to 1000 reviews), then orange to red (1000 to 2000 reviews)
        let color: UIColor
        if reviews < midReviews {
            // Interpolate from yellow (low reviews) to orange (midpoint)
            let normalizedReviews = Double(reviews - minReviews) / Double(midReviews - minReviews)
            color = interpolateColor(from: UIColor.yellow, to: UIColor.orange, factor: normalizedReviews)
        } else {
            // Interpolate from orange (midpoint) to red (high reviews)
            let normalizedReviews = Double(reviews - midReviews) / Double(maxReviews - midReviews)
            color = interpolateColor(from: UIColor.orange, to: UIColor.red, factor: normalizedReviews)
        }
        
        return color.withAlphaComponent(0.4)
        
        /*
        let minReviews = 0
        let midReviews = 1000
        let maxReviews = 2000
        
        // Calculate the position on the scale (0.0 to 1.0)
        let normalizedReviews = Double(min(max(0, reviews - minReviews), maxReviews - minReviews)) / Double(maxReviews - minReviews)
        
        // Interpolate between blue and yellow (0 to 1000 reviews), then yellow to red (1000 to 2000 reviews)
        let color: UIColor
        if reviews < midReviews {
            // Interpolate from blue (low reviews) to yellow (midpoint)
            color = interpolateColor(from: UIColor.blue, to: UIColor.yellow, factor: normalizedReviews)
        } else {
            // Interpolate from yellow (midpoint) to red (high reviews)
            let adjustedFactor = Double(min(max(0, reviews - midReviews), maxReviews - midReviews)) / Double(maxReviews - midReviews)
            color = interpolateColor(from: UIColor.yellow, to: UIColor.red, factor: adjustedFactor)
        }
        
        return color.withAlphaComponent(0.4)
        */
    }
    
    // Helper method to interpolate between two colors based on a factor
    private func interpolateColor(from startColor: UIColor, to endColor: UIColor, factor: Double) -> UIColor {
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        // Interpolate each color component
        let red = CGFloat((1 - factor) * Double(startRed) + factor * Double(endRed))
        let green = CGFloat((1 - factor) * Double(startGreen) + factor * Double(endGreen))
        let blue = CGFloat((1 - factor) * Double(startBlue) + factor * Double(endBlue))
        let alpha = CGFloat((1 - factor) * Double(startAlpha) + factor * Double(endAlpha))
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        
        /*
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)
        
        // Interpolate each color component
        let red = CGFloat((1 - factor) * Double(startRed) + factor * Double(endRed))
        let green = CGFloat((1 - factor) * Double(startGreen) + factor * Double(endGreen))
        let blue = CGFloat((1 - factor) * Double(startBlue) + factor * Double(endBlue))
        let alpha = CGFloat((1 - factor) * Double(startAlpha) + factor * Double(endAlpha))
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        */
    }
    
    
    private func drawHeatSpot(in context: CGContext, center: CGPoint, radius: CGFloat, color: UIColor) {
        context.saveGState()
        context.setBlendMode(.normal)
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
        context.restoreGState()
    }
}
