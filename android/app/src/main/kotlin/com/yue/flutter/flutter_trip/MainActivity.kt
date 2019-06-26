package com.yue.flutter.flutter_trip

import android.os.Bundle
import com.yue.flutter.plugin.asr.AsrPlugin

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    registerSelfPlugin()
  }
  // 自己插件的注册。
  private fun registerSelfPlugin() {
    AsrPlugin.registerWith(registrarFor("com.yue.flutter.plugin.asr.AsrPlugin"))
  }

}
