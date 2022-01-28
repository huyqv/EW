package com.example.sample

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.*
import android.net.wifi.*
import android.os.Build
import android.os.Handler
import android.provider.Settings
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.annotation.RequiresPermission
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import kotlinx.coroutines.Job

/*
AndroidManifest.xml:
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
*/
val Context.connectivityManager get() = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

val Context.wifiManager get() = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

val Context.isWifiEnabled: Boolean get() = wifiManager.isWifiEnabled

fun Context.wifiEnable(isEnable: Boolean) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
        @Suppress("DEPRECATION")
        wifiManager.isWifiEnabled = isEnable
        return
    }
    val intent = Intent(Settings.ACTION_WIFI_SETTINGS)
    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    startActivity(intent)
}

val Context.hasWifi: Boolean
    @SuppressLint("MissingPermission")
    get() {
        val cm = connectivityManager
        when {
            Build.VERSION.SDK_INT > Build.VERSION_CODES.O -> {
                val capabilities = cm.getNetworkCapabilities(cm.activeNetwork) ?: return false
                capabilities.run {
                    return hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                }
            }
            Build.VERSION.SDK_INT > Build.VERSION_CODES.M -> @Suppress("DEPRECATION") {
                val networkInfo = cm.activeNetworkInfo ?: return false
                return networkInfo.type == ConnectivityManager.TYPE_WIFI
            }
            else -> @Suppress("DEPRECATION") {
                return cm.activeNetworkInfo?.isConnected == true
            }
        }
    }

val wifiPermission = arrayOf(
    Manifest.permission.CHANGE_WIFI_STATE,
    Manifest.permission.ACCESS_WIFI_STATE,
    Manifest.permission.ACCESS_FINE_LOCATION,
    Manifest.permission.ACCESS_COARSE_LOCATION,
)

private fun Context.isGranted(permission: String): Boolean {
    return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
}

private val Context.isGrantedWifiPermission: Boolean
    get() {
        wifiPermission.forEach {
            if (!isGranted(it)) return false
        }
        return true
    }

fun Activity.onGrantedWifiPermission(
    onGranted: () -> Unit,
    onDenied: (List<String>) -> Unit
) {
    val notGrantedPermissions = mutableListOf<String>()
    val deniedPermissions = mutableListOf<String>()
    wifiPermission.forEach {
        when {
            isGranted(it) -> {

            }
            ActivityCompat.shouldShowRequestPermissionRationale(this, it) -> {
                deniedPermissions.add(it)
            }
            else -> {
                notGrantedPermissions.add(it)
            }
        }
    }
    if (notGrantedPermissions.isNotEmpty()) {
        ActivityCompat.requestPermissions(this, notGrantedPermissions.toTypedArray(), 101)
        return
    }
    if (deniedPermissions.isNotEmpty()) {
        onDenied(deniedPermissions.toList())
        return
    }
    onGranted.invoke()
}

/**
 * <receiver
 *      android:name="wee.digital.widget.extension.WifiReceiver"
 *      android:label="NetworkChangeReceiver"
 *      android:exported="true">
 *      <intent-filter>
 *      <action android:name="android.net.conn.CONNECTIVITY_CHANGE" />
 *      <action android:name="android.net.wifi.WIFI_STATE_CHANGED" />
 *      </intent-filter>
 * </receiver>
 */
class WifiHandler {

    var defaultSSID: String = ""
    var defaultPassword: String = ""

    fun log(s: String?) {
        Log.d("wifi", s ?: "null")
    }

    /**
     *
     */
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    fun listen(activity: Activity, onAvailable: () -> Unit, onLost: () -> Unit) {
        if (networkCallback != null) return
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                val cm = activity.connectivityManager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    // To make sure that requests don't go over mobile data
                    cm.bindProcessToNetwork(network)
                } else {
                    //cm.setProcessDefaultNetwork(network)
                }
                activity.runOnUiThread {
                    onAvailable()
                }
            }


            override fun onLost(network: Network) {
                val cm = activity.connectivityManager
                // This is to stop the looping request for OnePlus & Xiaomi models
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    cm.bindProcessToNetwork(null)
                }
                activity.runOnUiThread {
                    onLost()
                }
            }

            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities
            ) {
                //val hasWifi = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
            }
        }
        val cm = activity.connectivityManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            cm.registerDefaultNetworkCallback(callback)
        } else {
            val request: NetworkRequest = NetworkRequest.Builder()
                .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                .addCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
                .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
                .addCapability(NetworkCapabilities.NET_CAPABILITY_TRUSTED)
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .build()
            cm.registerNetworkCallback(request, callback)
        }
        networkCallback = callback
    }

    /**
     *
     */
    private var wifiScanReceiver: WifiReceiver? = null

    private var scanJob: Job? = null

    var isScanning: Boolean = false

    fun scan(activity: Activity, block: (List<ScanResult>) -> Unit) {
        isScanning = true
        wifiScanReceiver?.also {
            if (it.isOrderedBroadcast) {
                activity.unregisterReceiver(it)
            }
        }
        wifiScanReceiver = object : WifiReceiver() {
            override fun onReceived(context: Context, isSuccess: Boolean) {
                val activity = context as? AppCompatActivity ?: return
                block(activity.wifiManager.scanResults)
            }
        }
        val intentFilter = IntentFilter()
        intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        activity.registerReceiver(wifiScanReceiver, intentFilter)
        val wifiManager = activity.wifiManager
        wifiManager.startScan()
    }

    fun connect(activity: Activity) {
        scan(activity) {
            it.forEach { result ->
                if (result.SSID == defaultSSID) {
                    wifiConnect(activity, result)
                    return@forEach
                }
            }
        }
    }

    fun resumeScan(activity: Activity) {
        if (activity.isGrantedWifiPermission && isScanning) {
            connect(activity)
        }
    }

    fun stopScan() {
        scanJob?.cancel()
    }

    fun wifiConnect(
        activity: Activity,
        result: ScanResult,
        password: String = defaultPassword
    ) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                wifiConnectAndroidQ(activity, result, password)
            } else {
                wifiConnectAndroid(activity, result, password)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    @RequiresPermission(Manifest.permission.CHANGE_WIFI_STATE)
    fun wifiConnectAndroidQ(activity: Activity, result: ScanResult, password: String) {
        val networkSuggestion = WifiNetworkSuggestion.Builder()
            .setSsid(result.SSID)
            .setBssid(MacAddress.fromString(result.BSSID))
            .setWpa2Passphrase(password)
            .setPriority(10)

        val wifiManager = activity.wifiManager
        val status = wifiManager.addNetworkSuggestions(listOf(networkSuggestion.build()))
        if (status != WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS) {
            isScanning = false
            return
        }
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    // To make sure that requests don't go over mobile data
                    activity.connectivityManager.bindProcessToNetwork(network)
                } else {
                    //activity.connectivityManager.setProcessDefaultNetwork(network)
                }
            }

            override fun onLost(network: Network) {
                // This is to stop the looping request for OnePlus & Xiaomi models
                activity.connectivityManager.bindProcessToNetwork(null)
                isScanning = false
            }

            override fun onCapabilitiesChanged(
                network: Network,
                networkCapabilities: NetworkCapabilities
            ) {
                //val hasWifi = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
            }
        }
        val wifiNetworkSpecifier = WifiNetworkSpecifier.Builder()
            .setSsid(result.SSID)
            .setBssid(MacAddress.fromString(result.BSSID))
            .setWpa2Passphrase(password)
            .build()
        val networkRequest = NetworkRequest.Builder()
            .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
            .setNetworkSpecifier(wifiNetworkSpecifier)
            .build()
        activity.connectivityManager.requestNetwork(networkRequest, callback)
    }

    @Suppress("DEPRECATION")
    fun wifiConnectAndroid(
        activity: Activity,
        result: ScanResult,
        password: String
    ) {
        val capabilities = result.capabilities.uppercase()
        val conf = WifiConfiguration()
        // Please note the quotes. String should contain ssid in quotes
        conf.SSID = "\"" + result.SSID + "\""
        conf.status = WifiConfiguration.Status.ENABLED
        conf.priority = 40
        when {
            capabilities.contains("WEP") -> {
                log("Configuring WEP")
                conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
                conf.allowedProtocols.set(WifiConfiguration.Protocol.RSN)
                conf.allowedProtocols.set(WifiConfiguration.Protocol.WPA)
                conf.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN)
                conf.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.SHARED)
                conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP)
                conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104)
                if (password.matches("^[0-9a-fA-F]+$".toRegex())) {
                    conf.wepKeys[0] = password
                } else {
                    conf.wepKeys[0] = "\"" + password + "\""
                }
                conf.wepTxKeyIndex = 0
            }
            capabilities.contains("WPA") -> {
                log("Configuring WPA")
                conf.allowedProtocols.set(WifiConfiguration.Protocol.RSN)
                conf.allowedProtocols.set(WifiConfiguration.Protocol.WPA)
                conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK)
                conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP)
                conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP)
                conf.preSharedKey = "\"" + password + "\""
            }
            else -> {
                log("Configuring OPEN network")
                conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
                conf.allowedProtocols.set(WifiConfiguration.Protocol.RSN)
                conf.allowedProtocols.set(WifiConfiguration.Protocol.WPA)
                conf.allowedAuthAlgorithms.clear()
                conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP)
                conf.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP40)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.WEP104)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP)
                conf.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP)
            }
        }
        val wifiManager = activity.wifiManager
        val networkId = wifiManager.addNetwork(conf)
        log("Add result $networkId")
        val permission = ActivityCompat.checkSelfPermission(
            activity,
            Manifest.permission.ACCESS_FINE_LOCATION
        )
        if (permission != PackageManager.PERMISSION_GRANTED) {
            return
        }
        val list = wifiManager.configuredNetworks
        for (i in list) {
            if (i.SSID != null && i.SSID == "\"" + result.SSID + "\"") {
                log("WifiConfiguration SSID " + i.SSID)
                val isDisconnected = wifiManager.disconnect()
                log("isDisconnected : $isDisconnected")
                val isEnabled = wifiManager.enableNetwork(i.networkId, true)
                log("isEnabled : $isEnabled")
                val isReconnected = wifiManager.reconnect()
                log("isReconnected : $isReconnected")
                isScanning = false
                break
            }
        }
    }

    @RequiresPermission(Manifest.permission.CHANGE_WIFI_STATE)
    fun turnOnHotspot(activity: Activity) {
        val permission = ActivityCompat.checkSelfPermission(
            activity,
            Manifest.permission.ACCESS_FINE_LOCATION
        )
        if (permission != PackageManager.PERMISSION_GRANTED) {
            return
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            activity.wifiManager.startLocalOnlyHotspot(object :
                WifiManager.LocalOnlyHotspotCallback() {
                override fun onStarted(reservation: WifiManager.LocalOnlyHotspotReservation) {
                    val currentConfig = reservation.wifiConfiguration
                    Log.v(
                        "DANG", ("THE PASSWORD IS: "
                                + currentConfig?.preSharedKey
                                ) + " \n SSID is : "
                                + currentConfig?.SSID
                    )

                }

                override fun onStopped() {
                    super.onStopped()
                    Log.v("DANG", "Local Hotspot Stopped")
                }

                override fun onFailed(reason: Int) {
                    Log.v("DANG", "Local Hotspot failed to start")
                }
            }, Handler())
        }
    }
}

abstract class WifiReceiver : BroadcastReceiver() {
    final override fun onReceive(context: Context?, intent: Intent?) {
        context ?: return
        intent ?: return
        val success = intent.getBooleanExtra(WifiManager.EXTRA_RESULTS_UPDATED, false)
        onReceived(context, success)
    }

    abstract fun onReceived(context: Context, isSuccess: Boolean)
}