package wee.dev.ewa

import com.google.gson.JsonObject
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import retrofit2.Call
import retrofit2.Response

fun MethodChannel.Result?.safeSuccess(result: Any?) {
    result ?: return
    try {
        this?.success(result)
    } catch (e: Exception) {
    }
}

class MyMethodChannel(engine: FlutterEngine, private val int: Interface) : MethodChannel(
    engine.dartExecutor.binaryMessenger,
    "wee.dev.ewa/flutter"
) {

    init {
        setMethodCallHandler { call, result ->
            var arg = mapOf<String, String>()
            (call.arguments() as? Map<String, String>)?.also { arg = it }
            onMethodCall(call.method, result, arg)
        }
    }

    private fun onMethodCall(method: String, result: Result?, arg: Map<String, String>) {
        when (method) {
            "showToast" -> {
                val message = arg["message"]
                int.showToast(result, message)
            }

            "isWifiEnabled" -> {
                int.isWifiEnabled(result)
            }

            "wifiEnable" -> {
                val isEnable = arg["isEnable"].toBoolean()
                int.wifiEnable(result, isEnable)
            }

            "wifiListen" -> {
                val isEnable = arg["isEnable"].toBoolean()
                int.wifiListen(result, isEnable)
            }

            "currentWifi" -> {
                int.currentWifi(result)
            }

            "wifiScan" -> {
                int.wifiScan(result)
            }

            "startWifiAP" -> {
                int.startWifiAP(result)
            }
            "request" -> {
                val url = arg["url"] ?: return
                val body = arg["body"]?.toJsonObject() ?: return
                try {
                    doorService.request(url, body).enqueue(object : retrofit2.Callback<JsonObject> {
                        override fun onResponse(
                            call: Call<JsonObject>,
                            response: Response<JsonObject>
                        ) {
                            result.safeSuccess(response.body()?.toString())
                        }

                        override fun onFailure(call: Call<JsonObject>, t: Throwable) {
                            result.safeSuccess(t.toString())
                        }

                    })
                } catch (e: Exception) {
                    result.safeSuccess(e.toString())
                }
            }
        }
    }

    fun String?.toJsonObject(): JsonObject? {
        return parse(JsonObject::class.java)
    }

    interface Interface {

        fun showToast(result: Result?, s: String?)

        fun isWifiEnabled(result: Result?)

        fun wifiEnable(result: Result?, isEnable: Boolean)

        fun wifiListen(result: Result?, currentEnable: Boolean)

        fun wifiConnect(result: Result?)

        fun currentWifi(result: Result?)

        fun wifiScan(result: Result?)

        fun startWifiAP(result: Result?)

    }

}