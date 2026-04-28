import ComposeApp
import SwiftUI

/// Inset-grouped list of basic-command groups within a category.
/// Each group is a Section that expands to show its individual commands as code blocks.
struct BasicGroupsView: View {
    let categoryId: String
    let title: String
    let onManTap: (String) -> Void
    @StateObject private var store: BasicGroupsStore

    init(categoryId: String, title: String, onManTap: @escaping (String) -> Void = { _ in }) {
        self.categoryId = categoryId
        self.title = title
        self.onManTap = onManTap
        _store = StateObject(wrappedValue: BasicGroupsStore(categoryId: categoryId))
    }

    var body: some View {
        List {
            ForEach(store.state.basicGroups, id: \.id) { group in
                Section {
                    if store.isExpanded(groupId: group.id) {
                        let commands = store.commands(for: group.id)
                        ForEach(Array(commands.enumerated()), id: \.offset) { _, command in
                            CommandRow(
                                command: command,
                                onTapMan: { name in
                                    onManTap(name)
                                    Haptics.selection()
                                },
                                onTapUrl: store.tapUrl
                            )
                        }
                    }
                } header: {
                    Button {
                        store.toggle(groupId: group.id)
                    } label: {
                        HStack(spacing: 10) {
                            IconView(
                                assetName: IconHelperKt.assetNameForGroup(group: group),
                                size: 22,
                                tint: .brandRed
                            )
                            Text(group.description_)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Spacer(minLength: 0)
                            Image(systemName: store.isExpanded(groupId: group.id) ? "chevron.up" : "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .contentShape(Rectangle())
                    }
                    .hoverEffect(.highlight)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CommandRow: View {
    let command: BasicCommand
    let onTapMan: (String) -> Void
    let onTapUrl: (String) -> Void

    var body: some View {
        let elements = AppKt.getCommandList(command.command, mans: command.mans, hasBrackets: false)
        Text(buildAttributedString(elements: elements))
            .font(.shareTechMono(size: 13))
            .environment(\.openURL, OpenURLAction(handler: handleURL))
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
            .padding(.vertical, 4)
    }

    private func buildAttributedString(elements: [CommandElement]) -> AttributedString {
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

@MainActor
private final class BasicGroupsStore: ObservableObject {
    private let viewModel: BasicGroupsViewModel
    @Published private(set) var state = BasicGroupsUiState(
        basicGroups: [],
        collapsedMap: [:],
        commandsByGroupId: [:]
    )

    private var task: Task<Void, Never>?

    init(categoryId: String) {
        viewModel = KoinHelperKt.makeBasicGroupsViewModel(categoryId: categoryId)
        task = Task { [weak self] in
            guard let self else { return }
            for await s in self.viewModel.uiState {
                self.state = s
            }
        }
    }

    deinit {
        task?.cancel()
        viewModel.cancel()
    }

    func isExpanded(groupId: Int64) -> Bool {
        let collapsed = state.collapsedMap[KotlinLong(value: groupId)]?.boolValue ?? true
        return !collapsed
    }

    func commands(for groupId: Int64) -> [BasicCommand] {
        state.commandsByGroupId[KotlinLong(value: groupId)] ?? []
    }

    func toggle(groupId: Int64) {
        viewModel.toggleCollapse(id: groupId)
        Haptics.selection()
    }

    func tapUrl(_ url: String) {
        if let target = URL(string: url) {
            UIApplication.shared.open(target)
        }
    }
}
