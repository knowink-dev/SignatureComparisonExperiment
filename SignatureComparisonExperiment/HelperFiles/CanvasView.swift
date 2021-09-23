//
//  SignatureView.swift
//  MetalAndImages
//
//  Created by Paul Mayer on 5/25/21.
//

import AVFoundation
import UIKit


protocol CanvasViewDelegate {
    func signatureStarted(tag: Int)
    func signatureEnded(tag: Int)
}

//MARK: - Canvas Class
class CanvasView : UIImageView {
    
    var drawWidth : CGFloat = 1
    var drawColor : UIColor = UIColor.black
    var delegate : CanvasViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
    }
    
    func clearImage() {
        UIView.animate(withDuration: 0.15) {
            self.image = nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let delegate = delegate{
            delegate.signatureStarted(tag: self.tag)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        self.image?.draw(in: bounds)
        if let context = context {
            //Draw new lines in the image context
            drawStroke(context, touch)
        }

        // Update image
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let delegate = delegate {
            delegate.signatureEnded(tag: self.tag)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let delegate = delegate {
            delegate.signatureEnded(tag: self.tag)
        }
    }
    
    private func drawStroke(_ context: CGContext,_ touch: UITouch) {
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        // Set Color
        drawColor.setStroke()
        
        // Configure Line
        context.setLineWidth(1 * self.drawWidth)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: previousLocation.x, y: previousLocation.y))
        context.addLine(to: CGPoint(x: location.x, y: location.y))
        
        // Draw the stroke
        context.strokePath()
    }
    
}
