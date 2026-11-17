//
//  Product+Style.swift
//  Capstone Project
//
//  Created by user301577 on 11/16/26.
//

import SwiftUI

extension Product {
    enum Accent: String, Hashable {
        case ink, clay, sage, sand, dusk
    }

    var colors: [String] {
        guard let color, !color.isEmpty else { return [] }
        return color
            .split(whereSeparator: { $0 == "/" || $0 == "," })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var accent: Accent {
        let c = (color ?? "").lowercased()
        if ["black", "silver", "grey", "gray"].contains(where: c.contains) { return .ink }
        if ["red", "orange", "yellow"].contains(where: c.contains) { return .clay }
        if c.contains("green") { return .sage }
        if ["blue", "purple"].contains(where: c.contains) { return .dusk }
        if ["white", "tan", "brown"].contains(where: c.contains) { return .sand }
        let all: [Accent] = [.ink, .clay, .sage, .sand, .dusk]
        return all[abs(productId) % all.count]
    }

    var symbol: String {
        let n = name.lowercased()
        if ["bike", "bicycle"].contains(where: n.contains) { return "bicycle" }
        if n.contains("helmet") { return "figure.outdoor.cycle" }
        if ["jersey", "shorts", "gloves", "socks", "vest", "tights", "cap"].contains(where: n.contains) {
            return "tshirt.fill"
        }
        if ["bottle", "cage"].contains(where: n.contains) { return "waterbottle.fill" }
        if ["lock", "light", "pump", "rack", "stand"].contains(where: n.contains) { return "wrench.and.screwdriver.fill" }
        if ["frame", "wheel", "tire", "tube", "chain", "pedal", "brake", "crank",
            "saddle", "seat", "handlebar", "fork", "derailleur"].contains(where: n.contains) {
            return "gearshape.fill"
        }
        return "shippingbox.fill"
    }
}
