//
//  View+IfModifier.swift
//  CepatTanggapApp
//
//  Created by mohammad ichwan al ghifari on 14/06/25.
//

import Foundation
import SwiftUI
// Helper extension for conditional modifier
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
