package com.example.test_app

import android.content.Intent
import android.net.VpnService
import android.os.ParcelFileDescriptor
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.test_app/vpn"
    private var vpnInterface: ParcelFileDescriptor? = null
    private var vpnThread: Thread? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectVPN" -> {
                    val config = call.argument<String>("config")
                    if (config != null) {
                        connectVPN(config, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Config is null", null)
                    }
                }
                "disconnectVPN" -> {
                    disconnectVPN(result)
                }
                "getVPNStatus" -> {
                    result.success(vpnInterface != null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun connectVPN(config: String, result: MethodChannel.Result) {
        try {
            // Запрашиваем разрешение на VPN
            val intent = VpnService.prepare(this)
            if (intent != null) {
                startActivityForResult(intent, 0)
                result.error("VPN_PERMISSION_REQUIRED", "VPN permission required", null)
                return
            }

            // Парсим конфиг WireGuard
            val configMap = parseWireGuardConfig(config)
            
            // Извлекаем адрес клиента из секции [Interface]
            val interfaceSection = configMap["[Interface]"] as? Map<String, String> ?: emptyMap()
            val address = interfaceSection["Address"] ?: "10.0.0.2/32"
            val addressParts = address.split("/")
            val clientIp = addressParts[0]
            val prefixLength = addressParts.getOrNull(1)?.toIntOrNull() ?: 32
            
            // Создаем VPN интерфейс
            val builder = VpnService.Builder()
            builder.setSession("AmneziaWG VPN")
            builder.addAddress(clientIp, prefixLength)
            
            val dns = interfaceSection["DNS"]
            if (dns != null) {
                dns.split(",").forEach { dnsServer ->
                    builder.addDnsServer(dnsServer.trim())
                }
            } else {
                builder.addDnsServer("8.8.8.8")
                builder.addDnsServer("8.8.4.4")
            }
            
            builder.addRoute("0.0.0.0", 0)
            builder.setMtu(1420)
            
            vpnInterface = builder.establish()
            
            if (vpnInterface == null) {
                result.error("VPN_ERROR", "Failed to establish VPN interface", null)
                return
            }

            // Запускаем VPN туннель в отдельном потоке
            vpnThread = Thread {
                runVPNTunnel(vpnInterface!!, configMap)
            }
            vpnThread?.start()

            result.success(true)
        } catch (e: Exception) {
            result.error("VPN_ERROR", e.message ?: "Unknown error", null)
        }
    }

    private fun disconnectVPN(result: MethodChannel.Result) {
        try {
            vpnThread?.interrupt()
            vpnInterface?.close()
            vpnInterface = null
            vpnThread = null
            result.success(true)
        } catch (e: Exception) {
            result.error("VPN_ERROR", e.message, null)
        }
    }

    private fun parseWireGuardConfig(config: String): Map<String, Any> {
        val result = mutableMapOf<String, Any>()
        val lines = config.split("\n")
        
        var currentSection: String? = null
        val sections = mutableMapOf<String, MutableMap<String, String>>()
        
        for (line in lines) {
            val trimmed = line.trim()
            if (trimmed.isEmpty() || trimmed.startsWith("#")) continue
            
            // Проверяем секцию [Interface] или [Peer]
            if (trimmed.startsWith("[") && trimmed.endsWith("]")) {
                currentSection = trimmed.substring(1, trimmed.length - 1)
                sections[currentSection] = mutableMapOf()
                continue
            }
            
            val parts = trimmed.split("=", limit = 2)
            if (parts.size == 2) {
                val key = parts[0].trim()
                val value = parts[1].trim()
                
                if (currentSection != null) {
                    sections[currentSection]?.put(key, value)
                } else {
                    result[key] = value
                }
            }
        }
        
        result["[Interface]"] = sections["Interface"] ?: emptyMap()
        result["[Peer]"] = sections["Peer"] ?: emptyMap()
        
        return result
    }

    private fun runVPNTunnel(interface: ParcelFileDescriptor, config: Map<String, Any>) {
        // Упрощенная реализация VPN туннеля
        // В реальности для WireGuard нужна полная реализация протокола WireGuard
        // Это требует использования библиотеки wireguard-android или системного клиента
        
        // Пока что просто создаем интерфейс, реальный туннель будет работать через WireGuard клиент
        // Для полной реализации нужно:
        // 1. Использовать библиотеку wireguard-android
        // 2. Или использовать системный WireGuard клиент через Intent
        // 3. Или реализовать полный протокол WireGuard
        
        try {
            // Базовая реализация - просто держим интерфейс открытым
            // Реальный трафик будет обрабатываться через WireGuard протокол
            Thread.sleep(Long.MAX_VALUE)
        } catch (e: InterruptedException) {
            // Нормальное завершение
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            try {
                interface.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
