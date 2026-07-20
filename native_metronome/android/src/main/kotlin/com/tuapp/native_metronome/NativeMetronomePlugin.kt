package com.tuapp.native_metronome

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.io.InputStream

class NativeMetronomePlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  private var audioTrack: AudioTrack? = null

  // Datos fijos de tu archivo tick.wav (confirmados: 48000 Hz, estéreo, 16 bits)
  private val sampleRate = 48000
  private val channelCount = 2

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "native_metronome")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "ping" -> result.success("pong desde Kotlin")
      "start" -> {
        val bpm = call.argument<Int>("bpm") ?: 0
        if (bpm > 0) {
          startLoop(bpm)
        }
        result.success(null)
      }
      "stop" -> {
        stopLoop()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun readTickPcm(): ShortArray {
    // Lee el .wav desde res/raw, saltando el header de 44 bytes (formato WAV estándar)
    val resId = context.resources.getIdentifier("tick", "raw", context.packageName)
    val inputStream: InputStream = context.resources.openRawResource(resId)
    val buffer = ByteArrayOutputStream()
    val temp = ByteArray(4096)
    var bytesRead: Int
    while (inputStream.read(temp).also { bytesRead = it } != -1) {
      buffer.write(temp, 0, bytesRead)
    }
    inputStream.close()

    val allBytes = buffer.toByteArray()
    val headerSize = 44 // header WAV estándar de 44 bytes
    val pcmBytes = allBytes.copyOfRange(headerSize, allBytes.size)

    // Convertir bytes (little-endian, 16 bits) a shorts
    val shorts = ShortArray(pcmBytes.size / 2)
    for (i in shorts.indices) {
      val low = pcmBytes[i * 2].toInt() and 0xFF
      val high = pcmBytes[i * 2 + 1].toInt()
      shorts[i] = ((high shl 8) or low).toShort()
    }
    return shorts
  }

  private fun buildLoopBuffer(bpm: Int, tick: ShortArray): ShortArray {
    val intervalMs = 60000.0 / bpm
    val totalSamplesPerChannel = ((intervalMs / 1000.0) * sampleRate).toInt()
    val totalSamples = totalSamplesPerChannel * channelCount

    val loopBuffer = ShortArray(totalSamples) // inicializado en 0 = silencio
    val samplesToCopy = minOf(tick.size, totalSamples)
    System.arraycopy(tick, 0, loopBuffer, 0, samplesToCopy)

    return loopBuffer
  }

  private fun startLoop(bpm: Int) {
    stopLoop()

    val tick = readTickPcm()
    val loopBuffer = buildLoopBuffer(bpm, tick)

    val channelConfig = AudioFormat.CHANNEL_OUT_STEREO
    val minBufferSize = AudioTrack.getMinBufferSize(
      sampleRate,
      channelConfig,
      AudioFormat.ENCODING_PCM_16BIT
    )
    val bufferSizeBytes = maxOf(minBufferSize, loopBuffer.size * 2)

    audioTrack = AudioTrack(
      AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
        .build(),
      AudioFormat.Builder()
        .setSampleRate(sampleRate)
        .setChannelMask(channelConfig)
        .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
        .build(),
      bufferSizeBytes,
      AudioTrack.MODE_STATIC,
      0
    )

    audioTrack?.write(loopBuffer, 0, loopBuffer.size)
    audioTrack?.setLoopPoints(0, loopBuffer.size / channelCount, -1) // -1 = loop infinito
    audioTrack?.play()
  }

  private fun stopLoop() {
    audioTrack?.stop()
    audioTrack?.release()
    audioTrack = null
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    stopLoop()
    channel.setMethodCallHandler(null)
  }
}