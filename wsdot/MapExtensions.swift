//
//  MapExtensions.swift
//  WSDOT

import MapKit

//
// Extension by freak4pc
// https://gist.github.com/freak4pc/98c813d8adb8feb8aee3a11d2da1373f
//
public extension MKMultiPoint {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid,
                                              count: pointCount)

        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))

        return coords
    }
}
