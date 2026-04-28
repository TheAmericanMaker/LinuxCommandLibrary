package com.linuxcommandlibrary.app.ui.screens.search

import com.linuxcommandlibrary.app.data.BasicGroupMatch
import com.linuxcommandlibrary.app.data.CommandInfo

data class SearchUiState(
    val filteredCommands: List<CommandInfo> = emptyList(),
    val filteredBasicGroups: List<BasicGroupMatch> = emptyList(),
)
