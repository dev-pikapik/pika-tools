import SwiftUI

struct PassiveCopyView: View {
    private let copy = MainCopy.shared
    @State private var starting = false

    var body: some View {
        let caption = copy.leaderCaption
        ContentUnavailableView {
            Label("Another copy of pikapik is in charge", systemImage: "rectangle.on.rectangle")
        } description: {
            Text("This copy changes nothing on your Mac and takes over when the other copy quits.")
            Text(verbatim: caption.title)
            if let path = caption.path {
                Text(verbatim: path)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        } actions: {
            Button("Make This Copy the Main One") {
                starting = true
                copy.makeMain { starting = false }
            }
            .buttonStyle(.borderedProminent)
            .disabled(starting)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(Text(verbatim: "pikapik"))
        .onAppear { SettingsWindow.window?.title = "pikapik" }
    }
}
