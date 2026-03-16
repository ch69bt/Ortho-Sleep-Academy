package com.orthosleepacademy.app

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val METHOD_CHANNEL = "com.ortholutxmeter/lux"
        private const val EVENT_CHANNEL  = "com.ortholutxmeter/lux_stream"
        private const val MAX_LUX        = 300_000.0
        private const val MIN_LUX        = 0.0
    }

    private var sensorManager: SensorManager? = null
    private var lightSensor: Sensor? = null
    private var sensorEventListener: SensorEventListener? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)

        // MethodChannel: start / stop
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMeasurement" -> {
                    startListening()
                    result.success(null)
                }
                "stopMeasurement" -> {
                    stopListening()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // EventChannel: リアルタイムlux値を送信
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                stopListening()
                eventSink = null
            }
        })
    }

    private fun startListening() {
        if (lightSensor == null) {
            // 照度センサーなし（エミュレーター等）は0を送信
            eventSink?.success(0.0)
            return
        }
        val listener = object : SensorEventListener {
            override fun onSensorChanged(event: SensorEvent?) {
                val raw = event?.values?.firstOrNull()?.toDouble() ?: return
                val lux = raw.coerceIn(MIN_LUX, MAX_LUX)
                runOnUiThread { eventSink?.success(lux) }
            }
            override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
        }
        sensorEventListener = listener
        sensorManager?.registerListener(
            listener,
            lightSensor,
            SensorManager.SENSOR_DELAY_UI
        )
    }

    private fun stopListening() {
        sensorEventListener?.let { sensorManager?.unregisterListener(it) }
        sensorEventListener = null
    }

    override fun onPause() {
        super.onPause()
        stopListening()
    }

    override fun onResume() {
        super.onResume()
        // 画面に戻ってきたら自動再開
        if (eventSink != null) startListening()
    }
}
