package com.example.pothole_detector

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Build
import android.os.Bundle
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val methodChannelName: String = "method_channel"
    private val eventChannelName: String = "event_channel"

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var sensorManager: SensorManager
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                eventChannel =
                    EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, eventChannelName)

                eventChannel.setStreamHandler(
                    object : EventChannel.StreamHandler {
                        override fun onCancel(p0: Any?) {}
                        override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
                            if (p1 != null) {
                                    sensorManager.registerListener(
                                        MySensorListener(p1),
                                        sensorManager.getSensorList(Sensor.TYPE_GAME_ROTATION_VECTOR)[0],
                                        1000
                                    )
                            }
                        }
                    }
                )
    }
}


class MySensorListener(eventSink: EventChannel.EventSink) : SensorEventListener {
    private val _eventSink: EventChannel.EventSink = eventSink
    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    override fun onSensorChanged(event: SensorEvent?) {
        if (event != null)
            _eventSink.success(event.values)
    }
}

