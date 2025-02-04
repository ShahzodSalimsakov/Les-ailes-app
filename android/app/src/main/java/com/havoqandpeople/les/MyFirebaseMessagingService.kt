package com.havoqandpeople.les

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity

class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        try {
            // Validate the message source
            if (!isMessageFromTrustedSource(remoteMessage)) {
                Log.w(TAG, "Message received from untrusted source")
                return
            }

            // Validate and sanitize the intent data
            val route = remoteMessage.data["route"]
            if (route != null) {
                val intent = Intent(this, FlutterActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    // Remove any potentially dangerous flags
                    removeFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    removeFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
                    
                    // Add route data safely
                    if (ALLOWED_ROUTES.contains(route)) {
                        putExtra("route", route)
                        putExtra("notification_launched", true)
                    } else {
                        Log.w(TAG, "Invalid route received: $route")
                        return
                    }
                }
                
                // Launch activity with validated intent
                startActivity(intent)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error processing message", e)
        }
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "Refreshed token: $token")
        // Here you can send the token to your server
    }

    private fun isMessageFromTrustedSource(remoteMessage: RemoteMessage): Boolean {
        // Verify the sender ID matches our Firebase project
        return remoteMessage.from?.startsWith("/topics/") == true || 
               remoteMessage.from == FIREBASE_SENDER_ID
    }

    companion object {
        private const val TAG = "FCMService"
        private const val FIREBASE_SENDER_ID = "YOUR_SENDER_ID" // Replace with your Firebase Sender ID
        private val ALLOWED_ROUTES = setOf(
            "/home",
            "/delivery",
            "/pickup",
            "/profile"
        )
    }
} 
