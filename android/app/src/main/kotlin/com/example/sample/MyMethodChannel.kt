package com.example.sample

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MyMethodChannel(engine: FlutterEngine, private val int: Interface) : MethodChannel(
    engine.dartExecutor.binaryMessenger,
    "com.example.sample/flutter"
) {

    init {
        setMethodCallHandler { call, result ->
            val argument = call.arguments() as Map<String, String>;
            when (call.method) {
                "showToast" -> {
                    val message = argument["message"]
                    int.showToast(message)
                }
                "wifiList" -> {
                    int.wifiList()
                }
            }
        }
    }

    interface Interface {

        fun showToast(s: String?)

        fun wifiList(): List<Map<String, String>>

        fun isWifiEnabled(): Boolean

        fun wifiEnabled(isEnable: Boolean)

    }
}