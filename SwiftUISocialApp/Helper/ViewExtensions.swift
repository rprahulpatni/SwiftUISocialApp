//
//  ViewExtensions.swift
//  SwiftUISocialApp
//
//  Created by Neosoft on 19/07/23.
//

import Foundation
import UIKit
import SwiftUI

//MARK: View Extension for UI Building
extension View {
    func closeAllKeyboards() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func disbableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.6 : 1)
    }
    
    func hAlign(_ align: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: align)
    }
    
    func vAlign(_ align: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: align)
    }
    
    func border(_ width: CGFloat, _ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(color, lineWidth: width)
            }
    }
    
    func fillView(_ color: Color) -> some View {
        self
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(color)
            }
    }
}
