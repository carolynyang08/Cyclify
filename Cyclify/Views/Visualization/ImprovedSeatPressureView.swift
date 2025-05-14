//
//  ImprovedSeatPressureView.swift
//  Cyclify
//
//  Created by Carolyn Yang on 4/26/25.
//


import SwiftUI
import UIKit


struct ImprovedSeatPressureView: UIViewRepresentable {
    var pressureValues: [Int]
    var maxValue: Int
    var showLabels: Bool
    
    let sensorPositions: [SensorPosition] = [
        SensorPosition(x: 300, y: 350, name: "Bottom Right", sensorId: 9, type: .seat),
        SensorPosition(x: 100, y: 350, name: "Bottom Left", sensorId: 10, type: .seat),
        SensorPosition(x: 200, y: 250, name: "Center", sensorId: 11, type: .seat),
        SensorPosition(x: 150, y: 200, name: "Middle Left", sensorId: 12, type: .seat),
        SensorPosition(x: 200, y: 100, name: "Top", sensorId: 13, type: .seat)
    ]
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.subviews.forEach { $0.removeFromSuperview() }
        
        let seatView = UIView(frame: uiView.bounds)
        seatView.backgroundColor = .clear
        uiView.addSubview(seatView)
        
        let seatImageView = UIImageView(image: createSeatImage(size: seatView.bounds.size))
        seatImageView.frame = seatView.bounds
        seatView.addSubview(seatImageView)
        
        let heatMapView = UIView(frame: seatView.bounds)
        heatMapView.backgroundColor = .clear
        seatView.addSubview(heatMapView)
        

        let renderer = UIGraphicsImageRenderer(bounds: seatView.bounds)
        let heatMapImage = renderer.image { ctx in
            for position in sensorPositions {
                let sensorIndex = position.sensorId - 1
                guard sensorIndex >= 0 && sensorIndex < pressureValues.count else { continue }
                
                let value = pressureValues[sensorIndex]
                if value == 0 { continue }
                
                let normalizedValue = CGFloat(value) / CGFloat(maxValue) // Normalize to 0-1
                
                let scaledX = position.x / 400 * seatView.bounds.width
                let scaledY = position.y / 400 * seatView.bounds.height
                
                drawHeatSpot(ctx: ctx.cgContext, at: CGPoint(x: scaledX, y: scaledY), value: normalizedValue)
            }
        }
        
        let heatOverlayImageView = UIImageView(image: heatMapImage)
        heatOverlayImageView.frame = seatView.bounds
        heatMapView.addSubview(heatOverlayImageView)
        
        if showLabels {
            for position in sensorPositions {
                let scaledX = position.x / 400 * seatView.bounds.width
                let scaledY = position.y / 400 * seatView.bounds.height
                
                let label = UILabel(frame: CGRect(x: scaledX - 15, y: scaledY - 15, width: 30, height: 30))
                label.text = "\(position.sensorId)"
                label.textColor = .white
                label.textAlignment = .center
                label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
                label.backgroundColor = UIColor(red: 0.5, green: 0.4, blue: 0.7, alpha: 0.8) // Purple background like in the image
                label.layer.cornerRadius = 15
                label.layer.masksToBounds = true
                heatMapView.addSubview(label)
            }
        }
    }
    
    private func createSeatImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
          
            let path = UIBezierPath()
            
            let width = size.width
            let height = size.height

            path.move(to: CGPoint(x: width * 0.5, y: height * 0.1))
            
            path.addCurve(
                to: CGPoint(x: width * 0.6, y: height * 0.4),
                controlPoint1: CGPoint(x: width * 0.55, y: height * 0.15),
                controlPoint2: CGPoint(x: width * 0.6, y: height * 0.25)
            )

            path.addCurve(
                to: CGPoint(x: width * 0.7, y: height * 0.8),
                controlPoint1: CGPoint(x: width * 0.65, y: height * 0.5),
                controlPoint2: CGPoint(x: width * 0.7, y: height * 0.65)
            )
            
            path.addCurve(
                to: CGPoint(x: width * 0.3, y: height * 0.8),
                controlPoint1: CGPoint(x: width * 0.6, y: height * 0.9),
                controlPoint2: CGPoint(x: width * 0.4, y: height * 0.9)
            )
            
            path.addCurve(
                to: CGPoint(x: width * 0.4, y: height * 0.4),
                controlPoint1: CGPoint(x: width * 0.3, y: height * 0.65),
                controlPoint2: CGPoint(x: width * 0.35, y: height * 0.5)
            )
            
            path.addCurve(
                to: CGPoint(x: width * 0.5, y: height * 0.1),
                controlPoint1: CGPoint(x: width * 0.4, y: height * 0.25),
                controlPoint2: CGPoint(x: width * 0.45, y: height * 0.15)
            )
            
            ctx.cgContext.setFillColor(UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0).cgColor)
            path.fill()
            
            let dotPath = UIBezierPath()
            let dotSize: CGFloat = 2.0
            let dotSpacing: CGFloat = 8.0
            
            for x in stride(from: width * 0.3, to: width * 0.7, by: dotSpacing) {
                for y in stride(from: height * 0.1, to: height * 0.8, by: dotSpacing) {
                    let point = CGPoint(x: x, y: y)
                    if path.contains(point) {
                        dotPath.move(to: point)
                        dotPath.addArc(withCenter: point, radius: dotSize/2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
                    }
                }
            }
            
            ctx.cgContext.setFillColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0).cgColor)
            dotPath.fill()
            
            let channelPath = UIBezierPath()
            channelPath.move(to: CGPoint(x: width * 0.5, y: height * 0.1))
            channelPath.addLine(to: CGPoint(x: width * 0.5, y: height * 0.7))
            
            ctx.cgContext.setStrokeColor(UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            ctx.cgContext.setLineWidth(width * 0.03)
            channelPath.stroke()
          
            ctx.cgContext.setStrokeColor(UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0).cgColor)
            ctx.cgContext.setLineWidth(1.5)
            path.stroke()
        }
    }
    
    private func drawHeatSpot(ctx: CGContext, at position: CGPoint, value: CGFloat) {
        let radius = max(25, value * 50)
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor(red: 1, green: 0, blue: 0, alpha: min(0.9, value)).cgColor,
                UIColor(red: 1, green: 0.3, blue: 0, alpha: min(0.8, value * 0.9)).cgColor,
                UIColor(red: 1, green: 0.7, blue: 0, alpha: min(0.6, value * 0.7)).cgColor,
                UIColor.clear.cgColor
            ] as CFArray,
            locations: [0.0, 0.3, 0.7, 1.0]
        )!
        
        ctx.drawRadialGradient(
            gradient,
            startCenter: position,
            startRadius: 0.0,
            endCenter: position,
            endRadius: radius,
            options: .drawsBeforeStartLocation
        )
    }
}


struct ImprovedSeatPressureView_Previews: PreviewProvider {
    static var previews: some View {
        ImprovedSeatPressureView(
            pressureValues: [2000, 1800, 3000, 2500, 1500, 0, 0, 0, 2200, 2100, 1900, 2300, 1700, 0],
            maxValue: 4000,
            showLabels: true
        )
        .frame(height: 300)
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
