//
//  LaporanExtension.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 20/06/25.
//

import Foundation
extension Laporan {
    var fullFotoURL: URL? {
        if let foto = self.foto {
            if foto.starts(with: "http") {
                return URL(string: foto)
            } else {
                return URL(string: "http://192.168.100.12:3000\(foto)")
            }
        }
        return nil
    }
}
