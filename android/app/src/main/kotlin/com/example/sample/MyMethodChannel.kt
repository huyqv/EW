package com.example.sample

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MyMethodChannel(engine: FlutterEngine, private val int: Interface) : MethodChannel(
    engine.dartExecutor.binaryMessenger,
    "com.example.sample/flutter"
) {

    var result: Result? = null

    init {
        setMethodCallHandler { call, result ->
            this.result = result
            val argument = call.arguments() as Map<String, String>
            when (call.method) {
                "showToast" -> {
                    val message = argument["message"]
                    int.showToast(message)
                }
                "wifiEnable" -> {
                    val isEnable = argument["isEnable"]
                    int.wifiEnable(isEnable)
                }
                "isWifiEnabled"->{
                    int.isWifiEnabled(result)
                }
                "wifiListen" -> {
                    int.wifiListen(result)
                }
                "wifiList" -> {
                    int.wifiList()
                }
            }
        }
    }

    interface Interface {

        fun showToast(s: String?)

        fun wifiList(): List<Map<String, Any>>

        fun isWifiEnabled(result : Result?)

        fun wifiEnable(isEnable: String?)

        fun wifiListen(result : Result?)
    }
}