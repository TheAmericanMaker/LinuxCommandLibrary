package com.linuxcommandlibrary.app.screenshots

import com.linuxcommandlibrary.shared.platform.ShareHandler

object NoopShareHandler : ShareHandler {
    override fun shareText(text: String) {}
}
