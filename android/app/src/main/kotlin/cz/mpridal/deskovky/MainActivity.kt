package cz.mpridal.deskovky

import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.net.Uri
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var multicastLock: WifiManager.MulticastLock? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Network play (spec 14): Android drops Wi-Fi broadcasts unless the app
        // holds a multicast lock, so the join screen holds one while it looks
        // for rooms.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "deskovky/multicast").setMethodCallHandler { call, result ->
            when (call.method) {
                "acquire" -> {
                    val lock = multicastLock
                        ?: (applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager)
                            .createMulticastLock("deskovky")
                            .apply { setReferenceCounted(false) }
                    if (!lock.isHeld) lock.acquire()
                    multicastLock = lock
                    result.success(lock.isHeld)
                }
                "release" -> {
                    releaseMulticast()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
        // Self-update (spec 4): app version, the "unknown apps" permission and
        // handing a verified APK from cache/updates/ to the system installer.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "deskovky/update").setMethodCallHandler { call, result ->
            when (call.method) {
                "version" -> result.success(packageManager.getPackageInfo(packageName, 0).versionName)
                "canInstall" -> result.success(packageManager.canRequestPackageInstalls())
                "openInstallSettings" -> {
                    startActivity(
                        Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName"))
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                    )
                    result.success(null)
                }
                "install" -> {
                    val file = File(call.argument<String>("path") ?: "")
                    val updates = File(cacheDir, "updates").canonicalFile
                    if (!file.exists() || file.canonicalFile.parentFile != updates) {
                        result.error("bad_path", "Only verified downloads in cache/updates can be installed", null)
                    } else {
                        val uri = FileProvider.getUriForFile(this, "$packageName.updates", file)
                        startActivity(
                            Intent(Intent.ACTION_VIEW)
                                .setDataAndType(uri, "application/vnd.android.package-archive")
                                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK),
                        )
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun releaseMulticast() {
        multicastLock?.let { if (it.isHeld) it.release() }
    }

    override fun onDestroy() {
        releaseMulticast()
        super.onDestroy()
    }
}
