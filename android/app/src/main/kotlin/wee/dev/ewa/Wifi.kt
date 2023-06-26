package wee.dev.ewa

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
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.annotation.RequiresPermission
import androidx.core.app.ActivityCompat
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
object Wifi {
    fun log(s: String?) {
        Log.d("wifi", s ?: "null")
    }
}

val Context.connectivityManager get() = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

val Context.wifiManager get() = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

val Context.isWifiEnabled: Boolean get() = wifiManager.isWifiEnabled

fun Activity.setWifiEnable(isEnable: Boolean) {
    this.onGrantedWifiPermission(onGranted = {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            @Suppress("DEPRECATION")
            (Wifi.log("set wifi enable android Q: $isEnable"))
            wifiManager.isWifiEnabled = isEnable
        } else {
            Wifi.log("set wifi enable android <Q: $isEnable")
            navigateWifiSetting()
        }
    }, onDenied = {
        navigateWifiSetting()
    })
}

// Manifest: Permission.ACCESS_WIFI_STATE
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

fun Context.getCurrentWifi(): WifiInfo? {
    val cm = this.connectivityManager
    val networkInfo = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI)?:return null
    if (networkInfo.isConnected) {
        val wifiManager = this.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val connectionInfo = wifiManager.connectionInfo
        if (connectionInfo != null && !connectionInfo.ssid.isNullOrEmpty()) {
           return connectionInfo
        }
    }
    return null
}

class WifiHandler {

    var defaultSSID: String = ""
    var defaultPassword: String = ""

    /**
     *
     */
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    fun wifiListen(activity: Activity, onChanged: (Boolean) -> Unit) {
        val cm = activity.connectivityManager
        networkCallback?.also {
            cm.unregisterNetworkCallback(it)
        }
        val callback = object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) { activity.runOnUiThread { onChanged(true) } }
            override fun onLost(network: Network) { activity.runOnUiThread { onChanged(false) } }
            override fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {
                val hasWifi = networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                onChanged(hasWifi)
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            cm.registerDefaultNetworkCallback(callback)
        } else {
            val request: NetworkRequest = NetworkRequest.Builder()
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
        if (!activity.isGrantedWifiPermission){
            block(listOf())
            return
        }
        isScanning = true
        wifiScanReceiver?.also {
            if (it.isOrderedBroadcast) {
                activity.unregisterReceiver(it)
            }
        }
        wifiScanReceiver = object : WifiReceiver() {
            override fun onReceived(context: Context, isSuccess: Boolean) {
                val results = context.wifiManager.scanResults
                Wifi.log("new scan result: ${results.size}")
                block(results)
            }
        }
        val intentFilter = IntentFilter()
        intentFilter.addAction(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION)
        activity.registerReceiver(wifiScanReceiver, intentFilter)
        val wifiManager = activity.wifiManager
        wifiManager.startScan()
        Wifi.log("old scan result: ${wifiManager.scanResults.size}")
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            wifiConnectAndroidQ(activity, result, password)
            return
        }
        wifiConnectAndroid(activity, result, password)
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
                // To make sure that requests don't go over mobile data
                activity.connectivityManager.bindProcessToNetwork(network)
            }

            override fun onLost(network: Network) {
                // This is to stop the looping request for OnePlus & Xiaomi models
                activity.connectivityManager.bindProcessToNetwork(null)
                isScanning = false
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
                Wifi.log("Configuring WEP")
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
                Wifi.log("Configuring WPA")
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
                Wifi.log("Configuring OPEN network")
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
        Wifi.log("Add result $networkId")
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
                Wifi.log("WifiConfiguration SSID " + i.SSID)
                val isDisconnected = wifiManager.disconnect()
                Wifi.log("isDisconnected : $isDisconnected")
                val isEnabled = wifiManager.enableNetwork(i.networkId, true)
                Wifi.log("isEnabled : $isEnabled")
                val isReconnected = wifiManager.reconnect()
                Wifi.log("isReconnected : $isReconnected")
                isScanning = false
                break
            }
        }
    }

    @RequiresPermission(Manifest.permission.CHANGE_WIFI_STATE)
    fun turnOnHotspot(activity: Activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startWifiAPAndroidO(activity)
            return
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun startWifiAPAndroidO(activity: Activity) {
        Wifi.log("start wifi access point android Q")
        val permission = ActivityCompat.checkSelfPermission(
            activity,
            Manifest.permission.ACCESS_FINE_LOCATION
        )
        if (permission != PackageManager.PERMISSION_GRANTED) {
            return
        }
        activity.wifiManager.startLocalOnlyHotspot(object :
            WifiManager.LocalOnlyHotspotCallback() {
            override fun onStarted(reservation: WifiManager.LocalOnlyHotspotReservation) {
                val currentConfig = reservation.wifiConfiguration ?: return
                Wifi.log("hotspot: name: ${currentConfig.SSID}, password: ${currentConfig.preSharedKey}")

            }

            override fun onStopped() {
                super.onStopped()
                Wifi.log("Local Hotspot Stopped")
            }

            override fun onFailed(reason: Int) {
                Wifi.log("Local Hotspot failed to start")
            }
        }, Handler())
    }


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
abstract class WifiReceiver : BroadcastReceiver() {
    final override fun onReceive(context: Context?, intent: Intent?) {
        context ?: return
        intent ?: return
        val success = intent.getBooleanExtra(WifiManager.EXTRA_RESULTS_UPDATED, false)
        Wifi.log("wifi receiver is success: $success")
        onReceived(context, success)
    }
    abstract fun onReceived(context: Context, isSuccess: Boolean)
}