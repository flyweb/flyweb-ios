//
//  GradientView.swift
//  flyweb-ios
//
//  Created by Justin D'Arcangelo on 1/6/17.
//  Copyright © 2017 Justin D'Arcangelo. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class GradientView: UIView {
  @IBInspectable public var topColor: UIColor? {
    didSet {
      configureView()
    }
  }
  @IBInspectable public var bottomColor: UIColor? {
    didSet {
      configureView()
    }
  }
  
  public override class var layerClass: AnyClass {
    get {
      return CAGradientLayer.self
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureView()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  public override func tintColorDidChange() {
    super.tintColorDidChange()
    configureView()
  }
  
  func configureView() {
    let layer = self.layer as! CAGradientLayer
    let locations: [NSNumber] = [0.0, 1.0]
    layer.locations = locations
    let color1: UIColor = topColor ?? self.tintColor
    let color2: UIColor = bottomColor ?? UIColor.black
    let colors: Array <AnyObject> = [color1.cgColor, color2.cgColor]
    layer.colors = colors
  }
}
