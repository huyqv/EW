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
                "isWifiEnabled" -> {
                    int.isWifiEnabled(result)
                }
                "wifiEnable" -> {
                    val isEnable = argument["isEnable"]
                    int.wifiEnable(result, isEnable)
                }
                "wifiListen" -> {
                    int.wifiListen(result)
                }
                "wifiList" -> {
                    int.wifiList(result)
                }
            }
        }
    }

    interface Interface {

        fun showToast(s: String?)

        fun isWifiEnabled(result: Result?)

        fun wifiEnable(result: Result?, isEnable: String?)

        fun wifiListen(result: Result?)

        fun wifiConnect(result: Result?)

        fun wifiList(result: Result?)

    }
}