package com.example.sample

import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity : FlutterActivity(), MyMethodChannel.Interface {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MyMethodChannel(flutterEngine, this)
    }

    override fun onResume() {
        super.onResume()
        wifiHandler.resumeScan(this)
    }

    /**
     * [MyMethodChannel.Interface] implements
     */
    private val wifiHandler = WifiHandler().also {
        it.defaultSSID = "Huy"
        it.defaultPassword = "23121990huy"
    }

    override fun showToast(s: String?) {
        Toast.makeText(this, s ?: "null", Toast.LENGTH_SHORT).show()
    }

    override fun isWifiEnabled(result: Result?) {
        result?.success(isWifiEnabled)
    }

    override fun wifiEnable(result: Result?, isEnable: String?) {
        wifiEnable(isEnable == "true")
    }

    override fun wifiList(result: Result?) {
        wifiHandler.scan(this){
            
        }
    }

    override fun wifiConnect(result: Result?) {
        onGrantedWifiPermission({
            wifiHandler.connect(this)
        }, {

        })
    }

    override fun wifiListen(result: Result?) {
        wifiHandler.listen(this, {
            result?.success(true)
        }, {
            result?.success(false)
        })

    }


}
