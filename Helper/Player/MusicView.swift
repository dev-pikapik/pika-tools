import AppKit
import CoreImage

final class MusicView: NSView {
    private static let context = CIContext()
    private static let note = NSImage(systemSymbolName: "music.note", accessibilityDescription: nil)?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 140, weight: .light))
    private let glass = NSVisualEffectView()
    private let backdrop = NSView()
    private let dim = NSView()
    private let slot = NSView()
    private let cover = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let labels = NSStackView()

    override init(frame: NSRect) {
        super.init(frame: frame)
        glass.material = .underWindowBackground
        glass.blendingMode = .behindWindow
        glass.state = .active
        backdrop.wantsLayer = true
        backdrop.layer?.contentsGravity = .resizeAspectFill
        dim.wantsLayer = true
        dim.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        slot.wantsLayer = true
        slot.layer?.shadowColor = NSColor.black.cgColor
        slot.layer?.shadowOpacity = 0.35
        slot.layer?.shadowRadius = 18
        slot.layer?.shadowOffset = CGSize(width: 0, height: -6)
        cover.wantsLayer = true
        cover.layer?.cornerRadius = 10
        cover.layer?.masksToBounds = true
        cover.imageScaling = .scaleProportionallyUpOrDown
        cover.setAccessibilityElement(false)
        cover.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        cover.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabelColor
        for label in [titleLabel, subtitleLabel] {
            label.alignment = .center
            label.lineBreakMode = .byTruncatingTail
            label.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(490), for: .horizontal)
            label.setAccessibilityElement(false)
        }
        labels.orientation = .vertical
        labels.spacing = 4
        labels.addArrangedSubview(titleLabel)
        labels.addArrangedSubview(subtitleLabel)
        let column = NSStackView(views: [slot, labels])
        column.orientation = .vertical
        column.spacing = 20
        slot.addSubview(cover)
        for view in [glass, backdrop, dim, column, cover] as [NSView] { view.translatesAutoresizingMaskIntoConstraints = false }
        for view in [glass, backdrop, dim, column] { addSubview(view) }
        let width = slot.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.55)
        width.priority = NSLayoutConstraint.Priority(480)
        let height = slot.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -250)
        height.priority = NSLayoutConstraint.Priority(490)
        var constraints = [width, height, slot.heightAnchor.constraint(equalTo: slot.widthAnchor), slot.widthAnchor.constraint(lessThanOrEqualToConstant: 440)]
        constraints += [
            column.centerXAnchor.constraint(equalTo: centerXAnchor),
            column.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            column.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -48),
            labels.widthAnchor.constraint(equalTo: column.widthAnchor),
            cover.leadingAnchor.constraint(equalTo: slot.leadingAnchor),
            cover.trailingAnchor.constraint(equalTo: slot.trailingAnchor),
            cover.topAnchor.constraint(equalTo: slot.topAnchor),
            cover.bottomAnchor.constraint(equalTo: slot.bottomAnchor),
        ]
        for view in [glass, backdrop, dim] {
            constraints += [view.leadingAnchor.constraint(equalTo: leadingAnchor), view.trailingAnchor.constraint(equalTo: trailingAnchor),
                            view.topAnchor.constraint(equalTo: topAnchor), view.bottomAnchor.constraint(equalTo: bottomAnchor)]
        }
        NSLayoutConstraint.activate(constraints)
    }

    required init?(coder: NSCoder) { nil }

    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    func show(title: String, subtitle: String, cover image: NSImage?) {
        titleLabel.stringValue = title
        subtitleLabel.stringValue = subtitle
        subtitleLabel.isHidden = subtitle.isEmpty
        let blurred = image.flatMap(Self.blurred)
        backdrop.layer?.contents = blurred
        backdrop.isHidden = blurred == nil
        dim.isHidden = blurred == nil
        glass.isHidden = blurred != nil
        appearance = blurred == nil ? nil : NSAppearance(named: .darkAqua)
        if blurred == nil {
            cover.image = Self.note
            cover.contentTintColor = .tertiaryLabelColor
        } else {
            cover.image = image
            cover.contentTintColor = nil
        }
        slot.layer?.shadowOpacity = blurred == nil ? 0 : 0.35
    }

    private static func blurred(_ image: NSImage) -> CGImage? {
        guard let source = image.cgImage(forProposedRect: nil, context: nil, hints: nil), source.width > 0, source.height > 0 else { return nil }
        let picture = CIImage(cgImage: source)
        let scale = 96 / max(picture.extent.width, picture.extent.height)
        let small = picture.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return context.createCGImage(small.clampedToExtent().applyingGaussianBlur(sigma: 6).cropped(to: small.extent), from: small.extent)
    }
}
