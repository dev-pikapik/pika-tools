import SwiftUI

/// The dot that says "something new in here". It sits still: no pulse, so Reduce Motion needs nothing from it.
struct NewDot: View {
    var body: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 7, height: 7)
            .accessibilityLabel(Text("New"))
    }
}

/// The "New" tag next to a row title while the update's news is still unseen.
struct NewRowTag: View {
    let row: String

    var body: some View {
        if NewMarks.shared.isNew(row: row) { NewTag() }
    }
}

/// A section title with the "New" tag after it.
struct NewTitle: View {
    var title: LocalizedStringKey?
    let row: String

    var body: some View {
        HStack(spacing: 6) {
            if let title { Text(title) }
            NewRowTag(row: row)
        }
    }
}
