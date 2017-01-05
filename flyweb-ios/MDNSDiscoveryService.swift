//
//  MDNSDiscoveryService.swift
//  flyweb-ios
//
//  Created by Justin D'Arcangelo on 1/4/17.
//  Copyright © 2017 Justin D'Arcangelo. All rights reserved.
//

import Foundation

extension NSData {

  func castToCPointer<T>() -> T {
    let mem = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T.Type>.size)
    getBytes(mem, length: MemoryLayout<T.Type>.size)
    return mem.move()
  }

}

extension NetService {
  
  func addressesAsStrings() -> [String] {
    var strings = [String]()
    
    if (addresses?.count)! > 0 {
      for address in addresses! {
        let addressPointer: sockaddr_in = NSData.init(data: address).castToCPointer()
        let string = String.init(cString: inet_ntoa(addressPointer.sin_addr), encoding: String.Encoding.ascii)
        strings.append(string!)
      }
    }
    
    return strings
  }
  
  func url() -> URL {
    return URL.init(string: "http://\(addressesAsStrings().first!):\(port)")!
  }

}

@objc protocol MDNSDiscoveryServiceDelegate {

  func discoveryService(discoveryService: MDNSDiscoveryService, didFind service: NetService)
  func discoveryService(discoveryService: MDNSDiscoveryService, didRemove service: NetService)
  
  @objc optional func discoveryDidStart(discoveryService: MDNSDiscoveryService)
  @objc optional func discoveryDidStop(discoveryService: MDNSDiscoveryService)
  @objc optional func discovery(discoveryService: MDNSDiscoveryService, didUpdate service: NetService, txt: Data)

}

class MDNSDiscoveryService: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {

  private let serviceBrowser = NetServiceBrowser()
  
  private var type = ""
  private var domain = ""
  
  weak var delegate: MDNSDiscoveryServiceDelegate?
  
  var services = Set<NetService>()
  
  init(type: String, domain: String = "") {
    super.init()
    
    self.type = type
    self.domain = domain
    
    self.serviceBrowser.delegate = self
  }
  
  func start() {
    serviceBrowser.searchForServices(ofType: type, inDomain: domain)
    serviceBrowser.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)

    debugPrint("[MDNSDiscoveryService(type: \(type), domain: \(domain))] ", "start()")
  }
  
  func stop() {
    serviceBrowser.stop()
    
    debugPrint("[MDNSDiscoveryService(type: \(type), domain: \(domain))] ", "stop()")
  }
  
  func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
    services.remove(service)
    
    debugPrint("[MDNSDiscoveryService(type: \(type), domain: \(domain))] ",
        "netServiceBrowser(_ browser:", browser, " didRemove service:", service, " moreComing:", moreComing, ")")
    
    delegate?.discoveryService(discoveryService: self, didRemove: service)
  }
  
  func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
    delegate?.discoveryDidStart?(discoveryService: self)
  }
  
  func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
    delegate?.discoveryDidStop?(discoveryService: self)
  }
  
  func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
    debugPrint("[MDNSDiscoveryService(type: \(type), domain: \(domain))] ",
        "netServiceBrowser(_ browser:", browser, " didNotSearch errorDict:", errorDict, ")")
  }
  
  func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
    service.delegate = self
    service.resolve(withTimeout: 0)
    service.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    
    services.insert(service)
  }
  
  func netServiceDidResolveAddress(_ sender: NetService) {
    debugPrint("[MDNSDiscoveryService(type: \(type), domain: \(domain))] ",
        "netServiceDidResolveAddress(_ sender:", sender, ")")

    delegate?.discoveryService(discoveryService: self, didFind: sender)
  }
  
  func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
    debugPrint("[MDNSDiscoveryService(type: \(type), domain: \(domain))] ",
        "netService(_ sender:", sender, " didNotResolve errorDict:", errorDict, ")")
  }
  
  func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
    debugPrint("[MDNSDiscoveryService(type: \(type), domain: \(domain))] ",
        "netService(_ sender:", sender, " didUpdateTXTRecord data:", data, ")")
    
    delegate?.discovery?(discoveryService: self, didUpdate: sender, txt: data)
  }

}
