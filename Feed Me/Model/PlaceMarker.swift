//
//  PlaceMarker.swift
//  Feed Me
//
//  Created by wiserkuo on 2015/2/4.
//  Copyright (c) 2015年 Ron Kliffer. All rights reserved.
//
class PlaceMarker: GMSMarker {
  // 1
  let place: GooglePlace
  
  // 2
  init(place: GooglePlace) {
    self.place = place
    super.init()
    
    position = place.coordinate
    icon = UIImage(named: place.placeType+"_pin")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = kGMSMarkerAnimationPop
  }
}
