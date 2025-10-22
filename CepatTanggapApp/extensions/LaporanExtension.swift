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
                //kostan: http://192.168.0.107:3000/api
                //kontrakan:http://192.168.100.12:3000/api
                
                return URL(string: "http://127.0.0.1:3000\(foto)")
            }
        }
        return nil
    }
}
