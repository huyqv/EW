package com.example.sample

import android.content.Context
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.net.wifi.WifiManager





class MainActivity : FlutterActivity(), MyMethodChannel.Interface {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MyMethodChannel(flutterEngine, this)
    }

    /**
     * [MyMethodChannel.Interface] implements
     */
    override fun showToast(s: String?) {
        Toast.makeText(this, s ?: "null", Toast.LENGTH_SHORT).show()
    }

    override fun wifiList(): List<Map<String, String>> {
        val list = listOf<Map<String, String>>()
        return list
    }

    override fun isWifiEnabled(): Boolean {
        return wifiManager.isWifiEnabled
    }

    override fun wifiEnabled(isEnable: Boolean) {
        val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        wifi.isWifiEnabled = isEnable
    }


}
