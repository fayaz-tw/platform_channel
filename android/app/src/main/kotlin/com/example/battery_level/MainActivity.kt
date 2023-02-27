package com.example.battery_level

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.PersistableBundle
import android.util.Log


class MainActivity : FlutterActivity() {

  private var liveUpdateChannel: MethodChannel? = null

  fun sendLiveUpdate(update: String) {
    Log.d("live-update", "got event $update")
    if (liveUpdateChannel == null) {
      Log.d("live-update", "live update channel is null")
    }
    liveUpdateChannel?.invokeMethod("update", update)
  }

  private val CHANNEL = "battery"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    liveUpdateChannel = MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      "live_updates"
    )

    MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      CHANNEL
    ).setMethodCallHandler { call, result ->
      if (call.method == "getBatteryLevel") {
        val batteryLevel = getBatteryLevel()

        if (batteryLevel != -1) {
          result.success(batteryLevel)
        } else {
          result.error("UNAVAILABLE", "Battery level not available.", null)
        }
      } else {
        result.notImplemented()
      }
    }
  }

  private fun getBatteryLevel(): Int {
    val batteryLevel: Int
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      val intent = ContextWrapper(applicationContext).registerReceiver(
        null,
        IntentFilter(Intent.ACTION_BATTERY_CHANGED)
      )
      batteryLevel =
        intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(
          BatteryManager.EXTRA_SCALE,
          -1
        )
    }

    return batteryLevel
  }

  override fun onStart() {
    super.onStart()
    sendLiveUpdate("onStart")
  }

  override fun onStop() {
    super.onStop()
    sendLiveUpdate("onStop")
  }

  override fun onResume() {
    super.onResume()
    sendLiveUpdate("onResume")
  }

  override fun onRestart() {
    super.onRestart()
    sendLiveUpdate("onRestart")
  }

  override fun onCreate(savedInstanceState: Bundle?, persistentState: PersistableBundle?) {
    super.onCreate(savedInstanceState, persistentState)
    sendLiveUpdate("onCreate")
  }

  override fun onPause() {
    super.onPause()
    sendLiveUpdate("onPause")
  }
}
