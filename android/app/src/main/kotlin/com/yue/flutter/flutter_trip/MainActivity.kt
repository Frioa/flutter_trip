package com.yue.flutter.flutter_trip

import android.os.Bundle
import com.yue.flutter.plugin.asr.AsrPlugin

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import org.devio.flutter.splashscreen.SplashScreen

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    SplashScreen.show(this, true)
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    registerSelfPlugin()
  }
  // 自己插件的注册。
  private fun registerSelfPlugin() {
    AsrPlugin.registerWith(registrarFor("com.yue.flutter.plugin.asr.AsrPlugin"))
  }

}
