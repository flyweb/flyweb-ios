//
//  DetailViewController.swift
//  flyweb-ios
//
//  Created by Justin D'Arcangelo on 1/4/17.
//  Copyright © 2017 Justin D'Arcangelo. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet weak var detailWebView: UIWebView!

  func configureView() {
    // Update the user interface for the detail item.
    if let service = self.detailItem {
      title = service.name

      if (detailWebView != nil) {
        let url = service.url()
        
        detailWebView.loadRequest(URLRequest.init(url: url))
        debugPrint("[DetailViewController]", "Loading URL: ", url)
      }
    }
  }

  @IBAction func back() {
    detailWebView.goBack()
  }
  
  @IBAction func forward() {
    detailWebView.goForward()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view, typically from a nib.
    self.configureView()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
    // Dispose of any resources that can be recreated.
  }

  var detailItem: NetService? {
    didSet {
      // Update the view.
      self.configureView()
    }
  }

}
