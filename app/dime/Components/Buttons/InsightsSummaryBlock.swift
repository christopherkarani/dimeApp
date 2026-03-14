//
//  InsightsSummaryBlock.swift
//  dime
//
//  Created by Rafael Soh on 19/11/23.
//

import Foundation
import SwiftUI

struct InsightsSummaryBlockView: View {
    let income: Bool
    let amountString: String
    let showOverlay: Bool
    var action: () -> Void

    var color: Color {
        income ? Color.vGreen : Color.vRed
    }

    @State private var isPressed = false
    @State private var bounceCount = 0

    var body: some View {
        HStack(spacing: 6) {
            iconView

            Text(income ? "Income" : "Expenses")
                .font(.geist(.caption2, weight: .medium))
                .foregroundStyle(Color.vTertiary)

            amountView
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(showOverlay ? Color.vSurface : Color.vBg)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(showOverlay ? Color.vText.opacity(0.15) : Color.vBorder.opacity(0.3), lineWidth: 0.5)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            isPressed = true
            bounceCount += 1
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            action()
        }
    }

    @ViewBuilder
    private var iconView: some View {
        let base = Image(systemName: income ? "arrow.up.right" : "arrow.down.right")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(color)
            .frame(width: 22, height: 22)
            .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

        if #available(iOS 17.0, *) {
            base.symbolEffect(.bounce, value: bounceCount)
        } else {
            base
        }
    }

    @ViewBuilder
    private var amountView: some View {
        let base = Text(amountString)
            .font(.geistMono(.footnote, weight: .semibold))
            .monospacedDigit()
            .foregroundStyle(Color.vText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)

        if #available(iOS 16.0, *) {
            base.contentTransition(.numericText())
        } else {
            base
        }
    }
}
