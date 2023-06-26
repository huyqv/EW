package wee.dev.ewa

import android.app.Activity
import android.content.Intent

fun Activity.navigateWifiSetting() {
    val intent = Intent("android.settings.WIFI_SETTINGS")
    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    this.startActivity(intent)
}