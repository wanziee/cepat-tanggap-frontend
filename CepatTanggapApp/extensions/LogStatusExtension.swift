//
//  LogStatusExtension.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 26/06/25.
//

import Foundation

extension LogStatus {
    var fullFotoURL: URL? {
        if let foto = self.foto {
            if foto.starts(with: "http") {
                return URL(string: foto)
            } else {
                return URL(string: "http://192.168.0.107:3000\(foto)")
            }
        }
        return nil
    }
}
