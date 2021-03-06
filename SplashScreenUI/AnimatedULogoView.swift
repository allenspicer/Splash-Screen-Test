/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import QuartzCore
import Commons
public class AnimatedULogoView: UIView {
  private let strokeEndTimingFunction   = CAMediaTimingFunction(controlPoints: 1.00, 0.0, 0.35, 1.0)
  private let squareLayerTimingFunction      = CAMediaTimingFunction(controlPoints: 0.25, 0.0, 0.20, 1.0)
  private let circleLayerTimingFunction   = CAMediaTimingFunction(controlPoints: 0.65, 0.0, 0.40, 1.0)
  private let fadeInSquareTimingFunction = CAMediaTimingFunction(controlPoints: 0.15, 0, 0.85, 1.0)
  
  private let radius: CGFloat = 18
  private let squareLayerLength = 30.0
  private let startTimeOffset = 0.7 * kAnimationDuration
  
  private var circleLayer: CAShapeLayer!
  private var squareLayer: CAShapeLayer!
  private var lineLayer: CAShapeLayer!
  private var maskLayer: CAShapeLayer!
  
  var beginTime: CFTimeInterval = 0
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    circleLayer = generateCircleLayer()
    squareLayer = generateSquareLayer()
    maskLayer = generateMaskLayer()
    
    layer.mask = maskLayer
    layer.addSublayer(circleLayer)
    layer.addSublayer(squareLayer)
  }
  
  public func startAnimating() {
    beginTime = CACurrentMediaTime()
    layer.anchorPoint = CGPointZero
    
    animateMaskLayer()
    animateCircleLayer()
    //animateSquareLayer()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

extension AnimatedULogoView {
  
  private func generateMaskLayer()->CAShapeLayer {
    let layer = CAShapeLayer()
    layer.frame = CGRect(x: -radius, y: -radius, width: radius * 2.0, height: radius * 2.0)
    layer.allowsGroupOpacity = true
    layer.backgroundColor = UIColor.whiteColor().CGColor
    return layer
  }
  
  private func generateCircleLayer()->CAShapeLayer {
    let layer = CAShapeLayer()
    layer.lineWidth = radius
    layer.path = UIBezierPath(arcCenter: CGPointZero, radius: radius/2, startAngle: CGFloat(M_PI_2), endAngle: CGFloat(5*M_PI_2), clockwise: true).CGPath
    layer.strokeColor = UIColor.whiteColor().CGColor
    layer.fillColor = UIColor.clearColor().CGColor
    return layer
  }
  
  
  private func generateSquareLayer()->CAShapeLayer {
    let layer = CAShapeLayer()
    layer.position = CGPointZero
    layer.frame = CGRect(x: -squareLayerLength / 2.0, y: -squareLayerLength / 2.0, width: squareLayerLength, height: squareLayerLength)
    layer.cornerRadius = CGFloat(squareLayerLength / 2.0)
    layer.allowsGroupOpacity = true
    layer.backgroundColor = UIColor.fuberBlue().CGColor
    
    return layer
  }
}

extension AnimatedULogoView {
  
  private func animateMaskLayer() {
    // bounds
    let boundsAnimation = CABasicAnimation(keyPath: "bounds")
    boundsAnimation.fromValue = NSValue(CGRect: CGRect(x: 0.0, y: 0.0, width: radius * 2.0, height: radius * 2))
    boundsAnimation.toValue = NSValue(CGRect: CGRect(x: 0.0, y: 0.0, width: 2.0/3.0 * squareLayerLength, height: 2.0/3.0 * squareLayerLength))
    boundsAnimation.duration = kAnimationDurationDelay
    boundsAnimation.beginTime = kAnimationDuration - kAnimationDurationDelay
    boundsAnimation.timingFunction = circleLayerTimingFunction
    
    // cornerRadius
    let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
    cornerRadiusAnimation.beginTime = kAnimationDuration - kAnimationDurationDelay
    cornerRadiusAnimation.duration = kAnimationDurationDelay
    cornerRadiusAnimation.fromValue = radius
    cornerRadiusAnimation.toValue = 2
    cornerRadiusAnimation.timingFunction = circleLayerTimingFunction
    
    // Group
    let groupAnimation = CAAnimationGroup()
    groupAnimation.removedOnCompletion = false
    groupAnimation.fillMode = kCAFillModeBoth
    groupAnimation.beginTime = beginTime
    groupAnimation.repeatCount = Float.infinity
    groupAnimation.duration = kAnimationDuration
    groupAnimation.animations = [boundsAnimation, cornerRadiusAnimation]
    groupAnimation.timeOffset = startTimeOffset
    maskLayer.addAnimation(groupAnimation, forKey: "looping")
  }
  
  private func animateCircleLayer() {
    // strokeEnd
    let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
    strokeEndAnimation.timingFunction = strokeEndTimingFunction
    strokeEndAnimation.duration = kAnimationDuration - kAnimationDurationDelay
    strokeEndAnimation.values = [0.0, 1.0]
    strokeEndAnimation.keyTimes = [0.0, 1.0]
    
    // transform
    let transformAnimation = CABasicAnimation(keyPath: "transform")
    transformAnimation.timingFunction = strokeEndTimingFunction
    transformAnimation.duration = kAnimationDuration - kAnimationDurationDelay
    
    var startingTransform = CATransform3DMakeRotation(-CGFloat(M_PI_4), 0, 0, 1)
    startingTransform = CATransform3DScale(startingTransform, 0.25, 0.25, 1)
    transformAnimation.fromValue = NSValue(CATransform3D: startingTransform)
    transformAnimation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
    
    // Group
    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [strokeEndAnimation, transformAnimation]
    groupAnimation.repeatCount = Float.infinity
    groupAnimation.duration = kAnimationDuration
    groupAnimation.beginTime = beginTime
    groupAnimation.timeOffset = startTimeOffset
    
    circleLayer.addAnimation(groupAnimation, forKey: "looping")
  }
  
  private func animateSquareLayer() {
    // bounds
    let b1 = NSValue(CGRect: CGRect(x: 0.0, y: 0.0, width: 2.0/3.0 * squareLayerLength, height: 2.0/3.0  * squareLayerLength))
    let b2 = NSValue(CGRect: CGRect(x: 0.0, y: 0.0, width: squareLayerLength, height: squareLayerLength))
    let b3 = NSValue(CGRect: CGRectZero)
    
    let boundsAnimation = CAKeyframeAnimation(keyPath: "bounds")
    boundsAnimation.values = [b1, b2, b3]
    boundsAnimation.timingFunctions = [fadeInSquareTimingFunction, squareLayerTimingFunction]
    boundsAnimation.duration = kAnimationDuration
    boundsAnimation.keyTimes = [0, 1.0-kAnimationDurationDelay/kAnimationDuration, 1.0]
    
    // backgroundColor
    let backgroundColorAnimation = CABasicAnimation(keyPath: "backgroundColor")
    backgroundColorAnimation.fromValue = UIColor.whiteColor().CGColor
    backgroundColorAnimation.toValue = UIColor.fuberBlue().CGColor
    backgroundColorAnimation.timingFunction = squareLayerTimingFunction
    backgroundColorAnimation.fillMode = kCAFillModeBoth
    backgroundColorAnimation.beginTime = kAnimationDurationDelay * 2.0 / kAnimationDuration
    backgroundColorAnimation.duration = kAnimationDuration / (kAnimationDuration - kAnimationDurationDelay)
    
    // Group
    let groupAnimation = CAAnimationGroup()
    groupAnimation.animations = [boundsAnimation, backgroundColorAnimation]
    groupAnimation.repeatCount = Float.infinity
    groupAnimation.duration = kAnimationDuration
    groupAnimation.removedOnCompletion = false
    groupAnimation.beginTime = beginTime
    groupAnimation.timeOffset = startTimeOffset
    squareLayer.addAnimation(groupAnimation, forKey: "looping")
  }
}
