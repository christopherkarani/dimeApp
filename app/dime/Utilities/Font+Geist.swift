//
//  Font+Geist.swift
//  dime
//
//  Geist Sans + Geist Mono by Vercel (MIT License)
//  https://github.com/vercel/geist-font
//

import SwiftUI
import UIKit

// MARK: - Geist Font Extension

extension Font {

    // MARK: Geist Sans

    static func geist(_ style: Font.TextStyle, weight: GeistWeight = .regular) -> Font {
        let size = UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
        return .custom(weight.geistName, size: size, relativeTo: style)
    }

    static func geist(size: CGFloat, weight: GeistWeight = .regular) -> Font {
        .custom(weight.geistName, size: size)
    }

    static func geistFixed(size: CGFloat, weight: GeistWeight = .regular) -> Font {
        .custom(weight.geistName, fixedSize: size)
    }

    // MARK: Geist Mono (for numbers / data)

    static func geistMono(_ style: Font.TextStyle, weight: GeistMonoWeight = .regular) -> Font {
        let size = UIFont.preferredFont(forTextStyle: style.uiTextStyle).pointSize
        return .custom(weight.monoName, size: size, relativeTo: style)
    }

    static func geistMono(size: CGFloat, weight: GeistMonoWeight = .regular) -> Font {
        .custom(weight.monoName, size: size)
    }

    static func geistMonoFixed(size: CGFloat, weight: GeistMonoWeight = .regular) -> Font {
        .custom(weight.monoName, fixedSize: size)
    }
}

// MARK: - Weight Enums

enum GeistWeight {
    case light, regular, medium, semibold, bold

    var geistName: String {
        switch self {
        case .light:    return "Geist-Light"
        case .regular:  return "Geist-Regular"
        case .medium:   return "Geist-Medium"
        case .semibold: return "Geist-SemiBold"
        case .bold:     return "Geist-Bold"
        }
    }
}

enum GeistMonoWeight {
    case regular, medium, semibold

    var monoName: String {
        switch self {
        case .regular:  return "GeistMono-Regular"
        case .medium:   return "GeistMono-Medium"
        case .semibold: return "GeistMono-SemiBold"
        }
    }
}

// MARK: - TextStyle → UIFont.TextStyle Bridge

private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle:  return .largeTitle
        case .title:       return .title1
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .subheadline: return .subheadline
        case .body:        return .body
        case .callout:     return .callout
        case .footnote:    return .footnote
        case .caption:     return .caption1
        case .caption2:    return .caption2
        @unknown default:  return .body
        }
    }
}

// MARK: - UIFont Geist helpers

extension UIFont {
    static func geist(size: CGFloat, weight: GeistWeight = .regular) -> UIFont {
        UIFont(name: weight.geistName, size: size) ?? .systemFont(ofSize: size)
    }

    static func geistMono(size: CGFloat, weight: GeistMonoWeight = .regular) -> UIFont {
        UIFont(name: weight.monoName, size: size) ?? .monospacedSystemFont(ofSize: size, weight: .regular)
    }
}
