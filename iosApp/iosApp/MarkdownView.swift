import ComposeApp
import SwiftUI

/// Renders a list of TipSectionElement (the parsed markdown AST from KMP MarkdownParser)
/// natively in SwiftUI. The 4 element types each get their own renderer.
struct MarkdownView: View {
    let elements: [TipSectionElement]
    let onTapMan: (String) -> Void
    let onTapLink: (String) -> Void
    let onTapUrl: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(elements.enumerated()), id: \.offset) { _, element in
                TipSectionElementView(
                    element: element,
                    onTapMan: onTapMan,
                    onTapLink: onTapLink,
                    onTapUrl: onTapUrl
                )
            }
        }
    }
}

private struct TipSectionElementView: View {
    let element: TipSectionElement
    let onTapMan: (String) -> Void
    let onTapLink: (String) -> Void
    let onTapUrl: (String) -> Void

    var body: some View {
        switch onEnum(of: element) {
        case let .text(textCase):
            TextElementsView(
                elements: textCase.elements,
                onTapMan: onTapMan,
                onTapLink: onTapLink
            )
        case let .blockquote(bqCase):
            HStack(alignment: .top, spacing: 8) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 3)
                TextElementsView(
                    elements: bqCase.elements,
                    onTapMan: onTapMan,
                    onTapLink: onTapLink
                )
                .foregroundColor(.secondary)
            }
        case let .code(codeCase):
            CommandLineView(
                command: codeCase.command,
                elements: codeCase.elements,
                onTapMan: onTapMan,
                onTapUrl: onTapUrl
            )
        case let .table(tableCase):
            MarkdownTableView(
                headers: tableCase.headers,
                rows: tableCase.rows,
                onTapMan: onTapMan,
                onTapLink: onTapLink
            )
        }
    }
}

/// Renders [TextElement] as an inline AttributedString with bold/italic runs
/// and tappable man / action links.
private struct TextElementsView: View {
    let elements: [TextElement]
    let onTapMan: (String) -> Void
    let onTapLink: (String) -> Void

    var body: some View {
        Text(buildAttributedString())
            .environment(\.openURL, OpenURLAction(handler: handleURL))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func buildAttributedString() -> AttributedString {
        var result = AttributedString()
        for element in elements {
            switch onEnum(of: element) {
            case let .plain(plain):
                result += AttributedString(plain.text)
            case let .bold(bold):
                var part = AttributedString(bold.text)
                part.font = .body.bold()
                result += part
            case let .italic(italic):
                var part = AttributedString(italic.text)
                part.font = .body.italic()
                result += part
            case let .man(man):
                var part = AttributedString(man.man)
                part.foregroundColor = .brandRed
                part.link = URL(string: "lcl-man://\(man.man)")
                result += part
            case let .link(link):
                var part = AttributedString(link.text)
                part.foregroundColor = .brandRed
                part.link = URL(string: "lcl-action://\(link.action)")
                result += part
            }
        }
        return result
    }

    private func handleURL(_ url: URL) -> OpenURLAction.Result {
        switch url.scheme {
        case "lcl-man":
            onTapMan(url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
            return .handled
        case "lcl-action":
            onTapLink(url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
            return .handled
        default:
            return .systemAction
        }
    }
}

/// Renders a code block: the full command in monospace, with each CommandElement
/// rendered as plain text or tappable colored link.
private struct CommandLineView: View {
    let command: String
    let elements: [CommandElement]
    let onTapMan: (String) -> Void
    let onTapUrl: (String) -> Void

    var body: some View {
        Text(buildAttributedString())
            .font(.shareTechMono(size: 14))
            .environment(\.openURL, OpenURLAction(handler: handleURL))
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .textSelection(.enabled)
    }

    private func buildAttributedString() -> AttributedString {
        var result = AttributedString()
        for element in elements {
            switch onEnum(of: element) {
            case let .text(text):
                result += AttributedString(text.text)
            case let .man(man):
                var part = AttributedString(man.man)
                part.foregroundColor = .brandRed
                part.link = URL(string: "lcl-man://\(man.man)")
                result += part
            case let .url(urlElem):
                var part = AttributedString(urlElem.command)
                part.foregroundColor = .brandRed
                if let target = URL(string: urlElem.url) {
                    part.link = target
                }
                result += part
            }
        }
        return result
    }

    private func handleURL(_ url: URL) -> OpenURLAction.Result {
        if url.scheme == "lcl-man" {
            onTapMan(url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
            return .handled
        }
        onTapUrl(url.absoluteString)
        return .systemAction
    }
}

private struct MarkdownTableView: View {
    let headers: [[TextElement]]
    let rows: [[[TextElement]]]
    let onTapMan: (String) -> Void
    let onTapLink: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                ForEach(Array(headers.enumerated()), id: \.offset) { _, headerCell in
                    TextElementsView(
                        elements: headerCell,
                        onTapMan: onTapMan,
                        onTapLink: onTapLink
                    )
                    .font(.body.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Divider()
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(alignment: .top) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, cell in
                        TextElementsView(
                            elements: cell,
                            onTapMan: onTapMan,
                            onTapLink: onTapLink
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}
