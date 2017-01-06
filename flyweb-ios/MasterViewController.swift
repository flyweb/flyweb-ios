//
//  MasterViewController.swift
//  flyweb-ios
//
//  Created by Justin D'Arcangelo on 1/4/17.
//  Copyright © 2017 Justin D'Arcangelo. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MDNSDiscoveryServiceDelegate {

  @IBOutlet weak var tableView: UITableView!
  
  var detailViewController: DetailViewController? = nil
  var flywebDiscoveryService: MDNSDiscoveryService = MDNSDiscoveryService(type: "_flyweb._tcp")
  var httpDiscoveryService: MDNSDiscoveryService = MDNSDiscoveryService(type: "_http._tcp")
  var services = [NetService]()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view, typically from a nib.
    if let split = self.splitViewController {
      let controllers = split.viewControllers
      self.detailViewController = (controllers[controllers.count - 1] as! UINavigationController).topViewController as? DetailViewController
    }
    
    flywebDiscoveryService.delegate = self
    httpDiscoveryService.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    flywebDiscoveryService.start()
    httpDiscoveryService.start()

    if let indexPath = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: indexPath, animated: false)
    }
    
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    flywebDiscoveryService.stop()
    httpDiscoveryService.stop()

    super.viewWillDisappear(animated);
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      if let indexPath = self.tableView.indexPathForSelectedRow {
        let service = services[indexPath.row]
        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
        
        controller.detailItem = service
        controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        controller.navigationItem.leftItemsSupplementBackButton = true
      }
    }
  }

  // MARK: - Table View

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Nearby services"
  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.white
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return services.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let service = services[indexPath.row]
    cell.textLabel!.text = service.name
    return cell
  }

//  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//    cell.backgroundColor = UIColor.clear
//
//    let cornerRadius: CGFloat = 10
//    let layer: CAShapeLayer = CAShapeLayer()
//    let pathRef: CGMutablePath = CGMutablePath()
//    let bounds: CGRect = CGRect(x: 10, y: 0, width: cell.bounds.width - 75, height: cell.bounds.height)
//
//    var addLine: Bool = false
//    
//    if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1) {
//      pathRef.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
//    } else if (indexPath.row == 0) {
//      pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
//      pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY), tangent2End: CGPoint(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
//      pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
//      pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
//      addLine = true
//    } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1) {
//      pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
//      pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
//      pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY), tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
//      pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
//    } else {
//      pathRef.addRect(bounds)
//      addLine = true
//    }
//    
//    layer.path = pathRef
//    layer.fillColor = UIColor(red: 255 / 255.0, green: 255 / 255.0, blue: 255 / 255.0, alpha: 0.8).cgColor
//    
//    if (addLine == true) {
//      let lineLayer: CALayer = CALayer()
//      let lineHeight: CGFloat = (1.0 / UIScreen.main.scale)
//      lineLayer.frame = CGRect(x: bounds.minX + 10, y: bounds.size.height - lineHeight, width: bounds.size.width - 10, height: lineHeight)
//      lineLayer.backgroundColor = tableView.separatorColor?.cgColor
//      layer.addSublayer(lineLayer)
//    }
//
//    let testView: UIView = UIView(frame: bounds)
//    testView.layer.insertSublayer(layer, at: 0)
//    testView.backgroundColor = UIColor.clear
//
//    cell.backgroundView = testView
//  }
  
  func discoveryService(discoveryService: MDNSDiscoveryService, didFind service: NetService) {
    let indexPath = IndexPath(row: services.count, section: 0)
    services.append(service)
    self.tableView.insertRows(at: [indexPath], with: .automatic)
  }
  
  func discoveryService(discoveryService: MDNSDiscoveryService, didRemove service: NetService) {
    if let row = services.index(of: service) {
      let indexPath = IndexPath(row: row, section: 0)
      services.remove(at: indexPath.row)
      self.tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }

}
