package blocker.blocker

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import android.util.Log
import android.app.ActivityManager
import android.content.Context

class MyVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    Log.i("VPN", "VPN Service Started")
    val action = intent?.action
    if (action == "STOP_VPN") {
        Log.i("VPN", "Received STOP_VPN action")
        stopVPN()
        stopSelf()
        return START_NOT_STICKY
    }

    val blockedApps = intent?.getStringArrayListExtra("blockedApps") ?: arrayListOf()
    Log.d("VPN", "Received blocked apps: $blockedApps")

    stopVPN() // Clean up any existing VPN session

    val builder = Builder()
        .setSession("VPNBlocker")
        .addAddress("10.0.0.2", 32)
        .addDnsServer("8.8.8.8")
        .addRoute("0.0.0.0", 0)

    try {
        // ✅ Add disallowed apps only if list is not empty
        if (blockedApps.isNotEmpty()) {
            for (pkg in blockedApps) {
                try {
                    builder.addDisallowedApplication(pkg)
                    Log.d("VPN", "Blocked app (disallowed): $pkg")
                } catch (e: Exception) {
                    Log.w("VPN", "Couldn't disallow app: $pkg — ${e.message}")
                }
            }
        } else {
            Log.i("VPN", "No apps to block. Running VPN with full access.")
        }

        vpnInterface = builder.establish()
        if (vpnInterface != null) {
            Log.i("VPN", "✅ VPN interface established and running")
        } else {
            Log.e("VPN", "❌ Failed to establish VPN interface.")
        }

    } catch (e: Exception) {
        Log.e("VPN", "VPN establish failed: ${e.message}")
    }

    return START_NOT_STICKY
    }

    override fun onDestroy() {
        Log.d("VPN", "onDestroy called")
        stopVPN()
        // stopSelf()
        super.onDestroy()
    }

    private fun stopVPN() {
        Log.i("VPN", "Stopping VPN service")
        try {
            vpnInterface?.close()
            vpnInterface = null
            Log.i("VPN", "VPN stopped")
        } catch (e: Exception) {
            Log.e("VPN", "Error closing VPN interface: ${e.message}")
        }
    }
    fun isMyVpnServiceRunning(context: Context): Boolean {
    val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    for (service in manager.getRunningServices(Int.MAX_VALUE)) {
        if (service.service.className == MyVpnService::class.java.name) {
            return true
        }
    }
    return false
}
}
