package com.linuxcommandlibrary.app.screenshots

import com.linuxcommandlibrary.app.di.commonModule
import com.linuxcommandlibrary.shared.platform.AssetReader
import com.linuxcommandlibrary.shared.platform.PreferencesStorage
import com.linuxcommandlibrary.shared.platform.ReviewHandler
import com.linuxcommandlibrary.shared.platform.ShareHandler
import org.koin.core.module.Module
import org.koin.dsl.module

fun screenshotKoinModules(): List<Module> = listOf(
    module {
        single<AssetReader> { JvmAssetReader(resolveAssetsRoot()) }
        single<PreferencesStorage> { FakePreferencesStorage() }
        single<ShareHandler> { NoopShareHandler }
        single<ReviewHandler> { NoopReviewHandler }
    },
    commonModule,
)
