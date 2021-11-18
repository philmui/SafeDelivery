//
//  FileManagerExtension.swift
//  SafeDelivery
//
//  Created by Phil Mui on 11/15/21.
//

import Foundation

extension FileManager {
    private static func documentsURL() -> URL {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError()
        }
        return url
    }
    
    static func locationURL() -> URL {
        return documentsURL().appendingPathComponent("location")
    }
    
    static func mapDataURL() -> URL {
        return documentsURL().appendingPathComponent("mapData")
    }
}
