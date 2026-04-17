import CoreGraphics

struct KeyBinding: Identifiable, Hashable {
    let label: String
    let keyCode: CGKeyCode

    var id: CGKeyCode { keyCode }

    static let escapeKeyCode: CGKeyCode = 53

    static let defaultBindings: [KeyBinding] = [
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
}
