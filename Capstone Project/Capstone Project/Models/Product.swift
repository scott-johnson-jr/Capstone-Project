import Foundation

struct Product: Identifiable, Hashable {
    let id: UUID
    let name: String
    let brand: String
    let category: Category
    let price: Decimal
    let rating: Double
    let reviewCount: Int
    let summary: String
    let description: String
    let specs: [Spec]
    let colors: [String]
    let symbol: String
    let accent: Accent

    struct Spec: Identifiable, Hashable {
        let id = UUID()
        let label: String
        let value: String
    }

    enum Category: String, CaseIterable, Identifiable {
        case all = "All"
        case audio = "Audio"
        case wearables = "Wearables"
        case home = "Home"
        case bags = "Bags"

        var id: String { rawValue }
    }

    enum Accent: String, Hashable {
        case ink, clay, sage, sand, dusk
    }
}

enum Catalog {
    static let products: [Product] = [
        Product(
            id: UUID(),
            name: "Halo Buds",
            brand: "Northline",
            category: .audio,
            price: 129,
            rating: 4.7,
            reviewCount: 842,
            summary: "Everyday earbuds with a quiet, close fit.",
            description: "Halo Buds are tuned for long commutes and short calls. The seal stays put without pressure, and the case charges a full day from a twenty-minute top-up.",
            specs: [
                .init(label: "Battery", value: "8 hrs + 24 in case"),
                .init(label: "Charge", value: "USB-C, 20 min quick"),
                .init(label: "Weight", value: "4.6 g each")
            ],
            colors: ["Ink", "Clay", "Sand"],
            symbol: "airpods.pro",
            accent: .ink
        ),
        Product(
            id: UUID(),
            name: "Field Tote",
            brand: "Marrow",
            category: .bags,
            price: 168,
            rating: 4.8,
            reviewCount: 316,
            summary: "Waxed canvas tote that stands up on its own.",
            description: "Cut wide enough for a laptop and a market run. The base is reinforced, the strap is stitched through, and the wax finish darkens where you actually carry it.",
            specs: [
                .init(label: "Material", value: "Waxed cotton canvas"),
                .init(label: "Laptop", value: "Fits 14 inch"),
                .init(label: "Strap", value: "Adjustable, 28–48 in")
            ],
            colors: ["Olive", "Clay", "Black"],
            symbol: "bag.fill",
            accent: .sage
        ),
        Product(
            id: UUID(),
            name: "Lumen Lamp",
            brand: "Atelier 9",
            category: .home,
            price: 94,
            rating: 4.6,
            reviewCount: 509,
            summary: "A small lamp with a warm, dimmable pool of light.",
            description: "Lumen is meant for a nightstand or a desk corner. The shade is paper, the base is cast aluminum, and the dial remembers the last brightness you left it on.",
            specs: [
                .init(label: "Height", value: "11.5 in"),
                .init(label: "Bulb", value: "Included, 2700K"),
                .init(label: "Dimmer", value: "Touch dial")
            ],
            colors: ["Sand", "Ink"],
            symbol: "lamp.desk.fill",
            accent: .sand
        ),
        Product(
            id: UUID(),
            name: "Stride Band",
            brand: "Northline",
            category: .wearables,
            price: 79,
            rating: 4.4,
            reviewCount: 1204,
            summary: "A slim band for steps, sleep, and nothing else.",
            description: "Stride skips the screen. It tracks steps and sleep, buzzes for calls, and lasts five days. The clasp is the only moving part.",
            specs: [
                .init(label: "Battery", value: "5 days"),
                .init(label: "Water", value: "Swim-ready"),
                .init(label: "Band", value: "Silicone, S–L")
            ],
            colors: ["Ink", "Sage", "Clay"],
            symbol: "applewatch",
            accent: .dusk
        ),
        Product(
            id: UUID(),
            name: "Keepsake Speaker",
            brand: "Atelier 9",
            category: .audio,
            price: 210,
            rating: 4.9,
            reviewCount: 188,
            summary: "A table speaker that looks like it belongs there.",
            description: "One driver, a wool grille, and a volume knob you can find in the dark. It pairs over Bluetooth and has a line-in if you still own a record player.",
            specs: [
                .init(label: "Driver", value: "3 inch full range"),
                .init(label: "Battery", value: "12 hours"),
                .init(label: "Input", value: "Bluetooth, 3.5 mm")
            ],
            colors: ["Clay", "Sand"],
            symbol: "hifispeaker.fill",
            accent: .clay
        ),
        Product(
            id: UUID(),
            name: "Daypack 18",
            brand: "Marrow",
            category: .bags,
            price: 142,
            rating: 4.5,
            reviewCount: 640,
            summary: "An 18-liter pack with one main compartment.",
            description: "No dangling straps. A padded back, a sleeve for a bottle, and a front pocket that actually fits a notebook. Made to be worn every day, not just on a trail.",
            specs: [
                .init(label: "Volume", value: "18 L"),
                .init(label: "Fabric", value: "Recycled nylon"),
                .init(label: "Laptop", value: "Fits 13 inch")
            ],
            colors: ["Ink", "Sage"],
            symbol: "backpack.fill",
            accent: .ink
        )
    ]
}
