import ComposeApp
import SwiftUI

/// Native SwiftUI Commands tab. NavigationSplitView gives:
/// - iPhone: stack-style nav (sidebar pushes detail)
/// - iPad: persistent sidebar + detail pane
///
/// Selection is by command name. Man-link drilling appends to a NavigationPath
/// that lives on the detail column's NavigationStack.
struct CommandsTabView: View {
    @StateObject private var store = CommandsStore()
    @EnvironmentObject private var router: AppRouter
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var query = ""
    @State private var selectedCommand: String?
    @State private var path = NavigationPath()

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedCommand) {
                ForEach(store.visibleCommands(query: query), id: \.name) { command in
                    let isSelected = selectedCommand == command.name
                    HStack {
                        Text(command.name)
                        Spacer()
                        if store.bookmarkedNames.contains(command.name) {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(isSelected ? .white : .brandRed)
                                .font(.caption)
                        }
                    }
                    .tag(command.name)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Commands")
            .searchable(text: $query, prompt: "Search commands")
            .onChange(of: query) { newValue in
                store.search(query: newValue)
            }
        } detail: {
            NavigationStack(path: $path) {
                if let cmd = selectedCommand {
                    CommandDetailView(commandName: cmd, onManTap: { name in
                        path.append(name)
                    })
                    .id(cmd) // Force a fresh CommandDetailStore when sidebar selection changes
                    .navigationDestination(for: String.self) { name in
                        CommandDetailView(commandName: name, onManTap: { next in
                            path.append(next)
                        })
                        .id(name)
                    }
                } else {
                    DetailPlaceholder(systemImage: "terminal", message: "Select a command")
                }
            }
        }
        .onChange(of: router.commandDetailTarget) { newValue in
            if let newValue {
                selectedCommand = newValue
                path = NavigationPath()
                router.commandDetailTarget = nil
            }
        }
        // On iPad, pre-select the first command once data is loaded so the
        // detail pane shows real content instead of the empty placeholder.
        // On iPhone (compact), skip — auto-pushing to detail on launch is bad UX.
        .onChange(of: store.allCommands) { commands in
            if sizeClass == .regular && selectedCommand == nil,
               let first = commands.first
            {
                selectedCommand = first.name
            }
        }
    }
}

/// Owns the lifecycle of two KMP ViewModels and bridges their StateFlows
/// into SwiftUI-observable @Published properties via SKIE's AsyncSequence support.
@MainActor
final class CommandsStore: ObservableObject {
    private let listViewModel: CommandListViewModel
    private let searchViewModel: SearchViewModel

    @Published private(set) var allCommands: [CommandInfo] = []
    @Published private(set) var filteredCommands: [CommandInfo] = []
    @Published private(set) var bookmarkedNames: Set<String> = []

    private var listTask: Task<Void, Never>?
    private var bookmarkTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?

    init() {
        listViewModel = KoinHelperKt.makeCommandListViewModel()
        searchViewModel = KoinHelperKt.makeSearchViewModel()

        listTask = Task { [weak self] in
            guard let self else { return }
            for await commands in self.listViewModel.commands {
                self.allCommands = commands
            }
        }
        bookmarkTask = Task { [weak self] in
            guard let self else { return }
            for await names in self.listViewModel.bookmarkedNames {
                self.bookmarkedNames = names
            }
        }
        searchTask = Task { [weak self] in
            guard let self else { return }
            for await state in self.searchViewModel.uiState {
                self.filteredCommands = state.filteredCommands
            }
        }
    }

    deinit {
        listTask?.cancel()
        bookmarkTask?.cancel()
        searchTask?.cancel()
        searchViewModel.cancel()
    }

    func search(query: String) {
        searchViewModel.search(searchText: query)
    }

    func visibleCommands(query: String) -> [CommandInfo] {
        query.trimmingCharacters(in: .whitespaces).isEmpty ? allCommands : filteredCommands
    }
}
