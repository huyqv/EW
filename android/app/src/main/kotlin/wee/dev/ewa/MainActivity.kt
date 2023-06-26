package wee.dev.ewa

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONArray
import org.json.JSONObject

class MainActivity : FlutterActivity(),
    MyMethodChannel.Interface {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MyMethodChannel(flutterEngine, this)
    }

    override fun onResume() {
        super.onResume()
        moveTaskToBack(false)
        wifiHandler.resumeScan(this)
    }

    /**
     * [MyMethodChannel.Interface] implements
     */
    private val wifiHandler = WifiHandler().also {
        it.defaultSSID = "Huy"
        it.defaultPassword = "23121990huy"
    }

    override fun showToast(result: Result?, s: String?) {
        Toast.makeText(this, s ?: "null", Toast.LENGTH_SHORT).show()
    }

    override fun isWifiEnabled(result: Result?) {
        val isEnabled = wifiManager.isWifiEnabled
        Wifi.log("isEnabled: $isEnabled")
        result.safeSuccess(isEnabled)
    }

    override fun wifiEnable(result: Result?, isEnable: Boolean) {
        Wifi.log("setWifiEnable: $isEnable")
        setWifiEnable(isEnable)
    }

    override fun wifiScan(result: Result?) {
        Wifi.log("start wifi scan")
        wifiHandler.scan(this) { list ->
            val array = JSONArray()
            list.forEach { scanResult ->
                val o = JSONObject()
                o.put("ssid", scanResult.SSID)
                o.put("bssid", scanResult.BSSID)
                array.put(o)
            }
            val s = array.toString()
            Wifi.log("scan results: $s")
            result.safeSuccess(s)
        }
    }

    override fun wifiConnect(result: Result?) {
        onGrantedWifiPermission({
            wifiHandler.connect(this)
        }, {
            navigateWifiSetting()
        })
    }

    override fun wifiListen(result: Result?, currentEnable: Boolean) {
        Wifi.log("currentEnable: $currentEnable")
        wifiHandler.wifiListen(this) {
            if (it != currentEnable) {
                Wifi.log("listen: $it")
                result.safeSuccess(it)
            }
        }
    }

    override fun currentWifi(result: Result?) {
        val wifi = getCurrentWifi()
        if (wifi != null) {
            val o = JSONObject()
            o.put("ssid", wifi.ssid ?: "")
            o.put("bssid", wifi.bssid ?: "")
            Wifi.log("wifi info: $o")
            result.safeSuccess(o.toString())
        } else {
            result.safeSuccess(null)
        }
    }

    override fun startWifiAP(result: Result?) {
        wifiHandler.turnOnHotspot(this)
    }


}
