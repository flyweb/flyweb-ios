//
//  MasterViewController.swift
//  flyweb-ios
//
//  Created by Justin D'Arcangelo on 1/4/17.
//  Copyright © 2017 Justin D'Arcangelo. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, MDNSDiscoveryServiceDelegate {

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

    self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
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

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return services.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let service = services[indexPath.row]
    cell.textLabel!.text = service.name
    return cell
  }

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
