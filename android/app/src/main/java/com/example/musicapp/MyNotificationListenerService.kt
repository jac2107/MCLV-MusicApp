package com.example.musicapp

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MyNotificationListenerService : NotificationListenerService() {
    private val CHANNEL = "com.example.musicapp/notifications"

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        // Opcional: filtra notificaciones según sea necesario.
        if (sbn.packageName == packageName) {
            val extras = sbn.notification.extras
            val title = extras.getString("android.title") ?: "Sin título"
            val text = extras.getCharSequence("android.text")?.toString() ?: "Sin contenido"
            val postedTime = sbn.postTime.toString()

            // Prepara la información en un mapa
            val notificationData = mapOf(
                "title" to title,
                "text" to text,
                "postedTime" to postedTime
            )

            // Envía la información a Flutter usando un MethodChannel
            sendNotificationToFlutter(notificationData)
        }
    }

    private fun sendNotificationToFlutter(data: Map<String, String>) {
        // Obtén el FlutterEngine cacheado con un ID, por ejemplo "my_engine_id"
        val flutterEngine = FlutterEngineCache.getInstance().get("my_engine_id")
        if (flutterEngine != null) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onNotificationPosted", data)
        }
    }
}
