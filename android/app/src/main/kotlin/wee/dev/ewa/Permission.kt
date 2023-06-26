package wee.dev.ewa

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

val wifiPermission = arrayOf(
    Manifest.permission.CHANGE_WIFI_STATE,
    Manifest.permission.ACCESS_WIFI_STATE,
    Manifest.permission.ACCESS_FINE_LOCATION,
    Manifest.permission.ACCESS_COARSE_LOCATION,
)

fun Context.isGranted(permission: String): Boolean {
    return ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED
}

val Context.isGrantedWifiPermission: Boolean
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