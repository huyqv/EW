package com.example.sample

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.wifi.ScanResult
import android.net.wifi.WifiManager

val Context.wifiManager get() = this.getSystemService(Context.WIFI_SERVICE) as WifiManager

abstract class WifiListReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context?, intent: Intent?) {
        context ?: return
        val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val action = intent?.action ?: return
        if (WifiManager.SCAN_RESULTS_AVAILABLE_ACTION == action) {
            onReceive(context, wifiManager.scanResults)
        }
    }

    abstract fun onReceive(context: Context, list: List<ScanResult>)
}

class WifiReceiver {

    val receiver = object : WifiListReceiver() {
        override fun onReceive(context: Context, list: List<ScanResult>) {
            val sb = StringBuilder()
            for (scanResult in context.wifiManager.scanResults) {
                sb.append("\n")
                    .append(scanResult.SSID).append(" - ")
                    .append(scanResult.capabilities)
            }
        }
    }

}