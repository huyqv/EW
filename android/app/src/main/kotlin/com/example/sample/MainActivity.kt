package com.example.sample

import android.content.Context
import android.content.Intent
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiInfo
import android.os.Build
import android.provider.Settings
import android.widget.Toast
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.net.wifi.WifiManager

import android.net.NetworkInfo





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

    override fun wifiList(): List<Map<String, Any>> {
        val list = listOf<Map<String, Any>>()
        return list
    }

    override fun isWifiEnabled(result: MethodChannel.Result?) {
        result?.success(wifiManager.isWifiEnabled)
    }

    override fun wifiEnable(isEnable: String?) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            @Suppress("DEPRECATION")
            wifiManager.isWifiEnabled = isEnable == "true"
            return
        }
        val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivity(intent)
    }

    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private var unregisterNetworkObserver: LifecycleObserver? = null

    override fun wifiListen(result: MethodChannel.Result?) {
        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                showToast("onAvailable")
                result?.success(true)
            }

            override fun onLost(network: Network) {
                showToast("onLost")
                result?.success(false)
            }
        }

        val cm = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            cm.registerDefaultNetworkCallback(networkCallback!!)
        } else {
            val request: NetworkRequest = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .build()
            cm.registerNetworkCallback(request, networkCallback!!)
        }
        unregisterNetworkObserver?.also {
            lifecycle.removeObserver(it)
        }
        unregisterNetworkObserver = object : LifecycleObserver {
            @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
            fun onDestroy() {
                networkCallback?.also {
                    cm.unregisterNetworkCallback(it)
                }
            }
        }
        lifecycle.addObserver(unregisterNetworkObserver!!)

    }


}
