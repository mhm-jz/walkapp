package com.example.walkingapp

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.example.walkingapp/diagnostic_share",
        ).setMethodCallHandler { call, result ->
            if (call.method != "shareFile") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            try {
                val path = requireNotNull(call.argument<String>("path"))
                val file = File(path)
                val uri = FileProvider.getUriForFile(
                    this,
                    "$packageName.diagnostic_files",
                    file,
                )
                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = call.argument<String>("mimeType") ?: "application/json"
                    putExtra(Intent.EXTRA_STREAM, uri)
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                }
                startActivity(
                    Intent.createChooser(intent, call.argument<String>("title")),
                )
                result.success(null)
            } catch (error: Exception) {
                result.error("share_failed", error.javaClass.simpleName, null)
            }
        }
    }
}
