package cz.mpridal.deskovky

import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.net.Uri
import android.provider.Settings
import android.view.WindowManager
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var multicastLock: WifiManager.MulticastLock? = null

    // Network play (spec 14.3): a room QR code read by the phone camera opens
    // deskovky://join?ip&port&code. The link that started the app waits here
    // until Dart asks for it; later ones go straight to Dart.
    private var initialLink: String? = null
    private var linksChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        initialLink = joinLink(intent)
        linksChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "deskovky/links").apply {
            setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialLink" -> {
                        result.success(initialLink)
                        initialLink = null
                    }
                    else -> result.notImplemented()
                }
            }
        }
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
                "keepScreenOn" -> {
                    // While an update downloads: a locked phone would send the
                    // app to the background, where mobile data often stops.
                    if (call.argument<Boolean>("on") == true) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        joinLink(intent)?.let { linksChannel?.invokeMethod("link", it) }
    }

    /** The deskovky:// link of [intent]; none when reopened from recent apps. */
    private fun joinLink(intent: Intent?): String? {
        if (intent?.action != Intent.ACTION_VIEW) return null
        if (intent.flags and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY != 0) return null
        val uri = intent.data ?: return null
        return if (uri.scheme == "deskovky") uri.toString() else null
    }

    private fun releaseMulticast() {
        multicastLock?.let { if (it.isHeld) it.release() }
    }

    override fun onDestroy() {
        releaseMulticast()
        super.onDestroy()
    }
}
