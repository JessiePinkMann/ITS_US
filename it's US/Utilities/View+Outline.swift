//
//  View+Outline.swift
//  it's US
//
//  Created by Egor Zheliba on 03.05.2025.
//

import Foundation
import SwiftUI

extension View {
    /// Делает тонкую псевдо-обводку из четырёх теней
    func outline(color: Color = .black.opacity(0.2), width: CGFloat = 0.3) -> some View {
        self
            .shadow(color: color, radius: 0, x:  width, y:  width)
            .shadow(color: color, radius: 0, x: -width, y:  width)
            .shadow(color: color, radius: 0, x: -width, y: -width)
            .shadow(color: color, radius: 0, x:  width, y: -width)
    }
}
