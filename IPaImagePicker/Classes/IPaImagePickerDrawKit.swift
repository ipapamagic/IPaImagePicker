//
//  IPaImagePickerDrawKit.swift
//
//  Created by IPa Chen on 2017/8/22.
//  Copyright © 2017 AMagicStudio. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

class IPaImagePickerDrawKit : NSObject {

    //// Cache

    private struct Cache {
        static var imageOfPhotoButton: UIImage?
        static var photoButtonTargets: [AnyObject]?
    }

    //// Drawing Methods

    @objc dynamic class func drawFocusImage(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100), resizing: ResizingBehavior = .aspectFit, boundsWidth: CGFloat = 100, borderWidth: CGFloat = 0.5, lineWidth: CGFloat = 2, lineLength: CGFloat = 10) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 100, height: 100), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 100, y: resizedFrame.height / 100)


        //// Color Declarations
        let lineColor = UIColor(red: 0.960, green: 0.848, blue: 0.348, alpha: 1.000)
        let borderColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Variable Declarations
        let outerWidth: CGFloat = borderWidth * 2 + lineWidth
        let frameSizeWidth: CGFloat = boundsWidth - outerWidth
        let halfFrameSize: CGFloat = frameSizeWidth * 0.5
        let halfOuterWidth: CGFloat = outerWidth * 0.5
        let outerOffset: CGFloat = lineLength + borderWidth
        let outerOffset2: CGFloat = frameSizeWidth - borderWidth - lineLength
        let innerOffset: CGFloat = frameSizeWidth - lineLength

        //// border Drawing
        context.saveGState()
        context.translateBy(x: halfOuterWidth, y: halfOuterWidth)

        let borderPath = UIBezierPath()
        borderPath.move(to: CGPoint(x: frameSizeWidth, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: 0))
        borderPath.addLine(to: CGPoint(x: 0, y: frameSizeWidth))
        borderPath.addLine(to: CGPoint(x: frameSizeWidth, y: frameSizeWidth))
        borderPath.addLine(to: CGPoint(x: frameSizeWidth, y: 0))
        borderPath.close()
        borderPath.move(to: CGPoint(x: outerOffset, y: halfFrameSize))
        borderPath.addLine(to: CGPoint(x: 0, y: halfFrameSize))
        borderPath.move(to: CGPoint(x: halfFrameSize, y: outerOffset))
        borderPath.addLine(to: CGPoint(x: halfFrameSize, y: 0))
        borderPath.move(to: CGPoint(x: frameSizeWidth, y: halfFrameSize))
        borderPath.addLine(to: CGPoint(x: outerOffset2, y: halfFrameSize))
        borderPath.move(to: CGPoint(x: halfFrameSize, y: frameSizeWidth))
        borderPath.addLine(to: CGPoint(x: halfFrameSize, y: outerOffset2))
        borderColor.setStroke()
        borderPath.lineWidth = outerWidth
        borderPath.stroke()

        context.restoreGState()


        //// fillContent Drawing
        context.saveGState()
        context.translateBy(x: halfOuterWidth, y: halfOuterWidth)

        let fillContentPath = UIBezierPath()
        fillContentPath.move(to: CGPoint(x: 0, y: frameSizeWidth))
        fillContentPath.addLine(to: CGPoint(x: frameSizeWidth, y: frameSizeWidth))
        fillContentPath.addLine(to: CGPoint(x: frameSizeWidth, y: 0))
        fillContentPath.addLine(to: CGPoint(x: 0, y: 0))
        fillContentPath.addLine(to: CGPoint(x: 0, y: frameSizeWidth))
        fillContentPath.close()
        fillContentPath.move(to: CGPoint(x: lineLength, y: halfFrameSize))
        fillContentPath.addLine(to: CGPoint(x: 0, y: halfFrameSize))
        fillContentPath.move(to: CGPoint(x: frameSizeWidth, y: halfFrameSize))
        fillContentPath.addLine(to: CGPoint(x: innerOffset, y: halfFrameSize))
        fillContentPath.move(to: CGPoint(x: halfFrameSize, y: frameSizeWidth))
        fillContentPath.addLine(to: CGPoint(x: halfFrameSize, y: innerOffset))
        fillContentPath.move(to: CGPoint(x: halfFrameSize, y: lineLength))
        fillContentPath.addLine(to: CGPoint(x: halfFrameSize, y: 0))
        lineColor.setStroke()
        fillContentPath.lineWidth = lineWidth
        fillContentPath.stroke()

        context.restoreGState()
        
        context.restoreGState()

    }

    @objc dynamic class func drawPhotoButton(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 70, height: 70), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 70, height: 70), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 70, y: resizedFrame.height / 70)


        //// Color Declarations
        let borderColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        let buttonColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)

        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 0.5, y: 0.5, width: 69, height: 69))
        buttonColor.setFill()
        ovalPath.fill()
        borderColor.setStroke()
        ovalPath.lineWidth = 1
        ovalPath.stroke()


        //// Oval 2 Drawing
        let oval2Path = UIBezierPath(ovalIn: CGRect(x: 9, y: 9, width: 52, height: 52))
        buttonColor.setFill()
        oval2Path.fill()
        borderColor.setStroke()
        oval2Path.lineWidth = 2
        oval2Path.stroke()
        
        context.restoreGState()

    }

    @objc dynamic class func drawDownArrow(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 15, height: 10), resizing: ResizingBehavior = .aspectFit, arrowColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 15, height: 10), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 15, y: resizedFrame.height / 10)


        //// Rectangle Drawing
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: CGPoint(x: 1, y: 1))
        rectanglePath.addLine(to: CGPoint(x: 7.5, y: 8.5))
        rectanglePath.addLine(to: CGPoint(x: 14, y: 1))
        arrowColor.setStroke()
        rectanglePath.lineWidth = 2
        rectanglePath.lineCapStyle = .round
        rectanglePath.stroke()
        
        context.restoreGState()

    }

    //// Generated Images

    @objc dynamic class func imageOfFocusImage(boundsWidth: CGFloat = 100, borderWidth: CGFloat = 0.5, lineWidth: CGFloat = 2, lineLength: CGFloat = 10) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
            IPaImagePickerDrawKit.drawFocusImage(boundsWidth: boundsWidth, borderWidth: borderWidth, lineWidth: lineWidth, lineLength: lineLength)

        let imageOfFocusImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfFocusImage
    }

    @objc dynamic class var imageOfPhotoButton: UIImage {
        if Cache.imageOfPhotoButton != nil {
            return Cache.imageOfPhotoButton!
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: 70, height: 70), false, 0)
            IPaImagePickerDrawKit.drawPhotoButton()

        Cache.imageOfPhotoButton = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return Cache.imageOfPhotoButton!
    }

    @objc dynamic class func imageOfDownArrow(arrowColor: UIColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 15, height: 10), false, 0)
            IPaImagePickerDrawKit.drawDownArrow(arrowColor: arrowColor)

        let imageOfDownArrow = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return imageOfDownArrow
    }

    //// Customization Infrastructure

    @objc @IBOutlet dynamic var photoButtonTargets: [AnyObject]! {
        get { return Cache.photoButtonTargets }
        set {
            Cache.photoButtonTargets = newValue
            for target: AnyObject in newValue {
                let _ = target.perform(NSSelectorFromString("setImage:"), with: IPaImagePickerDrawKit.imageOfPhotoButton)
            }
        }
    }




    @objc(IPaImagePickerDrawKitResizingBehavior)
    enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
