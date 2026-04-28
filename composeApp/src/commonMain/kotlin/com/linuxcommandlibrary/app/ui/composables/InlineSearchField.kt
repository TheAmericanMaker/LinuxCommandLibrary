package com.linuxcommandlibrary.app.ui.composables

import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.linuxcommandlibrary.app.ui.AppIcons

@Composable
fun InlineSearchField(
    searchState: SearchState,
    placeholder: String,
    modifier: Modifier = Modifier,
) {
    OutlinedTextField(
        value = searchState.currentValue,
        onValueChange = { searchState.updateText(it) },
        modifier = modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        shape = RoundedCornerShape(28.dp),
        placeholder = { Text(placeholder) },
        leadingIcon = {
            Icon(imageVector = AppIcons.Search, contentDescription = null)
        },
        trailingIcon = if (searchState.searchText.isNotEmpty()) {
            {
                IconButton(onClick = { searchState.clearText() }) {
                    Icon(imageVector = AppIcons.Close, contentDescription = "Clear")
                }
            }
        } else {
            null
        },
        singleLine = true,
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = Color.Transparent,
            unfocusedBorderColor = Color.Transparent,
            disabledBorderColor = Color.Transparent,
            focusedContainerColor = MaterialTheme.colorScheme.surfaceContainerHigh,
            unfocusedContainerColor = MaterialTheme.colorScheme.surfaceContainerHigh,
        ),
    )
}
