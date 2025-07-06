package blocker.blocker

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "blocker.blocker/vpn"
    private var pendingBlockedApps: ArrayList<String>? = null
    private lateinit var methodResult: MethodChannel.Result

    companion object {
        private const val VPN_REQUEST_CODE = 1000
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVPN" -> {
                    val apps = call.argument<List<String>>("blockedApps") ?: listOf()
                    val vpnIntent = VpnService.prepare(this)

                    if (vpnIntent != null) {
                        pendingBlockedApps = ArrayList(apps)
                        methodResult = result
                        startActivityForResult(vpnIntent, VPN_REQUEST_CODE)
                    } else {
                        startVpnService(ArrayList(apps))
                        result.success(null)
                    }
                }

                "stopVPN" -> {
                    Log.i("VPN", "stopVPN method called from Flutter")
                    val intent = Intent(this, MyVpnService::class.java)
                    intent.action = "STOP_VPN"
                    startService(intent) // 💡 Actually stops the VPN
                    result.success(null)
                }
                "checkVPN" -> {
                    val isRunning = MyVpnService().isMyVpnServiceRunning(this)
                    result.success(isRunning)
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun startVpnService(apps: ArrayList<String>) {
        val intent = Intent(this, MyVpnService::class.java)
        intent.putStringArrayListExtra("blockedApps", apps)
        startService(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == VPN_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                pendingBlockedApps?.let {
                    startVpnService(it)
                }
                methodResult.success(null)
            } else {
                methodResult.error("VPN_DENIED", "User denied VPN permission", null)
            }
            pendingBlockedApps = null
        }
    }
}
