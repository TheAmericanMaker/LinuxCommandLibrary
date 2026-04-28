package com.linuxcommandlibrary.app.platform

import android.os.Build

actual val showAndroidTerminalTip: Boolean = Build.VERSION.SDK_INT >= 35
actual val defaultAutoExpandCommandSections: Boolean = false
