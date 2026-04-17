import CoreGraphics

struct KeyBinding: Identifiable, Hashable {
    let label: String
    let keyCode: CGKeyCode

    var id: CGKeyCode { keyCode }

    static let escapeKeyCode: CGKeyCode = 53
    static let availableLabels = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
    ]

    static func bindings(for order: KeyOrder, layout: KeyboardLayout) -> [KeyBinding] {
        switch layout {
        case .qwerty:
            return qwertyBindings(for: order)
        case .programmerDvorak:
            return programmerDvorakBindings(for: order)
        }
    }

    static func binding(for label: String, layout: KeyboardLayout) -> KeyBinding? {
        let normalizedLabel = label.uppercased()
        let bindings: [KeyBinding]

        switch layout {
        case .qwerty:
            bindings = qwertyAlphabeticalBindings
        case .programmerDvorak:
            bindings = programmerDvorakAlphabeticalBindings
        }

        return bindings.first { $0.label == normalizedLabel }
    }

    private static func qwertyBindings(for order: KeyOrder) -> [KeyBinding] {
        switch order {
        case .homeRowFirst:
            return qwertyHomeRowFirstBindings
        case .alphabetical:
            return qwertyAlphabeticalBindings
        }
    }

    private static func programmerDvorakBindings(for order: KeyOrder) -> [KeyBinding] {
        switch order {
        case .homeRowFirst:
            return programmerDvorakHomeRowFirstBindings
        case .alphabetical:
            return programmerDvorakAlphabeticalBindings
        }
    }

    private static let qwertyHomeRowFirstBindings: [KeyBinding] = [
        KeyBinding(label: "A", keyCode: 0),
        KeyBinding(label: "S", keyCode: 1),
        KeyBinding(label: "D", keyCode: 2),
        KeyBinding(label: "F", keyCode: 3),
        KeyBinding(label: "G", keyCode: 5),
        KeyBinding(label: "H", keyCode: 4),
        KeyBinding(label: "J", keyCode: 38),
        KeyBinding(label: "K", keyCode: 40),
        KeyBinding(label: "L", keyCode: 37),
        KeyBinding(label: "Q", keyCode: 12),
        KeyBinding(label: "W", keyCode: 13),
        KeyBinding(label: "E", keyCode: 14),
        KeyBinding(label: "R", keyCode: 15),
        KeyBinding(label: "T", keyCode: 17),
        KeyBinding(label: "Y", keyCode: 16),
        KeyBinding(label: "U", keyCode: 32),
        KeyBinding(label: "I", keyCode: 34),
        KeyBinding(label: "O", keyCode: 31),
        KeyBinding(label: "P", keyCode: 35),
        KeyBinding(label: "Z", keyCode: 6),
        KeyBinding(label: "X", keyCode: 7),
        KeyBinding(label: "C", keyCode: 8),
        KeyBinding(label: "V", keyCode: 9),
        KeyBinding(label: "B", keyCode: 11),
        KeyBinding(label: "N", keyCode: 45),
        KeyBinding(label: "M", keyCode: 46)
    ]

    private static let qwertyAlphabeticalBindings: [KeyBinding] = [
        KeyBinding(label: "A", keyCode: 0),
        KeyBinding(label: "B", keyCode: 11),
        KeyBinding(label: "C", keyCode: 8),
        KeyBinding(label: "D", keyCode: 2),
        KeyBinding(label: "E", keyCode: 14),
        KeyBinding(label: "F", keyCode: 3),
        KeyBinding(label: "G", keyCode: 5),
        KeyBinding(label: "H", keyCode: 4),
        KeyBinding(label: "I", keyCode: 34),
        KeyBinding(label: "J", keyCode: 38),
        KeyBinding(label: "K", keyCode: 40),
        KeyBinding(label: "L", keyCode: 37),
        KeyBinding(label: "M", keyCode: 46),
        KeyBinding(label: "N", keyCode: 45),
        KeyBinding(label: "O", keyCode: 31),
        KeyBinding(label: "P", keyCode: 35),
        KeyBinding(label: "Q", keyCode: 12),
        KeyBinding(label: "R", keyCode: 15),
        KeyBinding(label: "S", keyCode: 1),
        KeyBinding(label: "T", keyCode: 17),
        KeyBinding(label: "U", keyCode: 32),
        KeyBinding(label: "V", keyCode: 9),
        KeyBinding(label: "W", keyCode: 13),
        KeyBinding(label: "X", keyCode: 7),
        KeyBinding(label: "Y", keyCode: 16),
        KeyBinding(label: "Z", keyCode: 6)
    ]

    private static let programmerDvorakHomeRowFirstBindings: [KeyBinding] = [
        KeyBinding(label: "A", keyCode: 0),
        KeyBinding(label: "O", keyCode: 1),
        KeyBinding(label: "E", keyCode: 2),
        KeyBinding(label: "U", keyCode: 3),
        KeyBinding(label: "I", keyCode: 5),
        KeyBinding(label: "D", keyCode: 4),
        KeyBinding(label: "H", keyCode: 38),
        KeyBinding(label: "T", keyCode: 40),
        KeyBinding(label: "N", keyCode: 37),
        KeyBinding(label: "S", keyCode: 41),
        KeyBinding(label: "P", keyCode: 15),
        KeyBinding(label: "Y", keyCode: 17),
        KeyBinding(label: "F", keyCode: 16),
        KeyBinding(label: "G", keyCode: 32),
        KeyBinding(label: "C", keyCode: 34),
        KeyBinding(label: "R", keyCode: 31),
        KeyBinding(label: "L", keyCode: 35),
        KeyBinding(label: "Q", keyCode: 7),
        KeyBinding(label: "J", keyCode: 8),
        KeyBinding(label: "K", keyCode: 9),
        KeyBinding(label: "X", keyCode: 11),
        KeyBinding(label: "B", keyCode: 45),
        KeyBinding(label: "M", keyCode: 46),
        KeyBinding(label: "W", keyCode: 43),
        KeyBinding(label: "V", keyCode: 47),
        KeyBinding(label: "Z", keyCode: 44)
    ]

    private static let programmerDvorakAlphabeticalBindings: [KeyBinding] = [
        KeyBinding(label: "A", keyCode: 0),
        KeyBinding(label: "B", keyCode: 45),
        KeyBinding(label: "C", keyCode: 34),
        KeyBinding(label: "D", keyCode: 4),
        KeyBinding(label: "E", keyCode: 2),
        KeyBinding(label: "F", keyCode: 16),
        KeyBinding(label: "G", keyCode: 32),
        KeyBinding(label: "H", keyCode: 38),
        KeyBinding(label: "I", keyCode: 5),
        KeyBinding(label: "J", keyCode: 8),
        KeyBinding(label: "K", keyCode: 9),
        KeyBinding(label: "L", keyCode: 35),
        KeyBinding(label: "M", keyCode: 46),
        KeyBinding(label: "N", keyCode: 37),
        KeyBinding(label: "O", keyCode: 1),
        KeyBinding(label: "P", keyCode: 15),
        KeyBinding(label: "Q", keyCode: 7),
        KeyBinding(label: "R", keyCode: 31),
        KeyBinding(label: "S", keyCode: 41),
        KeyBinding(label: "T", keyCode: 40),
        KeyBinding(label: "U", keyCode: 3),
        KeyBinding(label: "V", keyCode: 47),
        KeyBinding(label: "W", keyCode: 43),
        KeyBinding(label: "X", keyCode: 11),
        KeyBinding(label: "Y", keyCode: 17),
        KeyBinding(label: "Z", keyCode: 44)
    ]
}
