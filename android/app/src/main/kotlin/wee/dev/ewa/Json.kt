package wee.dev.ewa

import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.reflect.TypeToken
import org.json.JSONException
import org.json.JSONObject
import java.io.StringReader
import java.math.BigDecimal
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap
import kotlin.reflect.KClass

class JsonFieldNullException(key: String) : NullPointerException("json parse $key is null")

/**
 * Parse [JsonObject]/[JsonArray]/[String] to Kotlin Object/List<Object>
 */
val convertFactory: Gson by lazy {
    Gson()
}


fun <T> JsonElement?.parse(cls: Class<T>): T? {
    return this?.toString()?.parse(cls)
}

fun <T> JsonElement?.parse(cls: Class<Array<T>>): List<T>? {
    return this?.toString()?.parse(cls)
}

fun <T : Any> JsonElement?.parse(cls: KClass<T>): T? {
    return this?.toString()?.parse(cls)
}

fun <T : Any> JsonElement?.parse(cls: KClass<Array<T>>): List<T>? {
    return this?.toString()?.parse(cls)
}

fun <T> String?.parse(cls: Class<T>): T? {
    this ?: return null
    if (isNullOrEmpty()) {
        return null
    }
    return try {
        return convertFactory.fromJson(this, cls)
    } catch (ignore: Exception) {
        null
    }
}

fun <T : Any> JsonElement?.parseOrThrow(cls: KClass<T>): T {
    val s = this?.toString()
    return convertFactory.fromJson(this, cls.java)
}

fun JsonElement?.toMap(): Map<String, Any?>? {
    try {
        this ?: return null
        return convertFactory.fromJson(this, object : TypeToken<java.util.HashMap<String?, Any?>?>() {}.type)
    } catch (ignore: Exception) {
        return null
    }
}

fun <T> String?.parse(cls: Class<Array<T>>): List<T>? {
    this ?: return null
    if (isNullOrEmpty()) {
        return null
    }
    return try {
        return convertFactory.fromJson(StringReader(this), cls).toList()
    } catch (ignore: Exception) {
        null
    }
}

fun <T : Any> String?.parse(cls: KClass<T>): T? {
    return this?.parse(cls.java)
}

fun <T : Any> String?.parse(cls: KClass<Array<T>>): List<T>? {
    return this?.parse(cls.java)
}

fun <T> T.toJsonObject(): JsonObject? {
    return try {
        if (this is String){
            return parse(JsonObject::class.java)
        }
        val element = convertFactory.toJsonTree(this, object : TypeToken<T>() {}.type)
        return element.asJsonObject
    } catch (ignore: Exception) {
        null
    }
}

fun <T> Collection<T?>?.toJsonArray(): JsonArray? {
    if (this.isNullOrEmpty()) return null
    val jsonArray = JsonArray()
    this.forEach {
        when (it) {
            is JsonObject -> {
                jsonArray.add(it)
            }
            is String -> {
                jsonArray.add(it as String)
            }
            is Number -> {
                jsonArray.add(it as Number)
            }
            else -> it.toJsonObject()?.also { obj ->
                jsonArray.add(obj)
            }
        }
    }
    if (jsonArray.isEmpty()) return null
    return jsonArray
}

/**
 * [String] to [JsonObject]/[JsonArray]
 */
fun String?.toJsonObject(): JsonObject? {
    return parse(JsonObject::class.java)
}

fun String?.toJsonArray(): JsonArray? {
    return parse(JsonArray::class.java)
}

/**
 * [JsonElement] to [JsonObject]/[JsonArray]
 */
fun JsonElement?.toJsonObject(): JsonObject? {
    this ?: return null
    if (this.isJsonNull) return null
    if (!this.isJsonObject) return null
    return this.asJsonObject
}

fun JsonElement?.toJsonArray(): JsonArray? {
    this ?: return null
    if (isJsonNull) return null
    if (!isJsonArray) return null
    val arr = asJsonArray
    if (arr.size() == 0) return null
    return arr
}

/**
 * [JsonArray]
 */
fun JsonArray?.getObject(index: Int): JsonObject? {
    this ?: return null
    if (index !in 0 until this.size()) return null
    if (this[index].isJsonNull) return null
    if (!this[index].isJsonObject) return null
    return this[index].asJsonObject
}

fun JsonArray?.getArray(index: Int): JsonArray? {
    this ?: return null
    if (index !in 0 until this.size()) return null
    if (this[index].isJsonNull) return null
    if (!this[index].isJsonArray) return null
    return this[index].asJsonArray
}

fun JsonArray?.getElement(index: Int): JsonElement? {
    this ?: return null
    if (index !in 0 until this.size()) return null
    if (this[index].isJsonNull) return null
    return this[index]
}

fun JsonArray?.addObject(obj: JsonObject?) {
    this ?: return
    obj ?: return
    if (obj.isJsonNull) return
    this.add(obj)
}

fun JsonArray?.addArray(array: JsonArray?) {
    this ?: return
    array ?: return
    if (array.size() == 0) return
    this.addAll(array)
}

fun JsonArray?.isEmpty(): Boolean {
    this ?: return true
    return this.size() == 0
}

fun JsonArray?.notEmpty(): Boolean {
    this ?: return false
    return this.size() != 0
}

/**
 * [JsonObject] properties setter
 */
fun JsonObject.put(key: String, value: String?): JsonObject {
    if (null != value) addProperty(key, value)
    return this
}

fun JsonObject.put(key: String, value: Boolean?): JsonObject {
    if (null != value) addProperty(key, value)
    return this
}

fun JsonObject.put(key: String, value: Number?): JsonObject {
    if (null != value) addProperty(key, value)
    return this
}

fun JsonObject.put(key: String, value: JsonElement?): JsonObject {
    if (null != value) add(key, value)
    return this
}

fun JsonObject.put(key: String, block: JsonObject.() -> Unit): JsonObject {
    val value = JsonObject()
    value.block()
    add(key, value)
    return this
}

fun <T> JsonObject.put(key: String, value: List<T?>?): JsonObject {
    add(key, value.toJsonArray() ?: JsonArray())
    return this
}

/**
 * [JsonObject] properties getter
 */
fun JsonObject?.obj(string: String): JsonObject? {
    this ?: return null
    if (!has(string)) return null
    if (!get(string).isJsonObject) return null
    return get(string).asJsonObject
}

fun JsonObject?.array(key: String): JsonArray? {
    this ?: return null
    if (!has(key)) return null
    if (get(key).isJsonNull) return null
    if (!get(key).isJsonArray) return null
    val arr = get(key).asJsonArray
    if (arr.size() == 0) return null
    return arr
}

fun JsonObject?.bool(key: String, default: Boolean = false): Boolean {
    this ?: return default
    if (!has(key)) return default
    if (get(key).isJsonNull) return default
    return get(key)?.asBoolean ?: default
}

fun JsonObject?.strOrThrow(key: String): String {
    try {
        val s = this!!.get(key)?.asString
        if (s.isNullOrEmpty()) throw JsonFieldNullException(key)
        return s
    } catch (ignore: Exception) {
        throw JsonFieldNullException(key)
    }
}

fun JsonObject?.str(key: String, default: String? = null): String? {
    this ?: return default
    if (!has(key)) return default
    if (get(key).isJsonNull) return default
    val s = get(key)?.asString
    if (s.isNullOrEmpty()) return null
    return s
}

fun JsonObject?.intOrNull(key: String): Int? {
    try {
        this ?: return null
        if (!has(key)) return null
        if (get(key).isJsonNull) return null
        return get(key)?.asInt ?: get(key)?.asString?.toIntOrNull()
    } catch (ignore: Exception) {
        return this!!.get(key)?.asString?.toDoubleOrNull()?.toInt()
    }
}

fun JsonObject?.intOrThrow(key: String): Int {
    return intOrNull(key) ?: throw JsonFieldNullException(key)
}

fun JsonObject?.int(key: String, default: Int = 0): Int {
    return intOrNull(key) ?: default
}

fun JsonObject?.longOrNull(key: String): Long? {
    try {
        this ?: return null
        if (!has(key)) return null
        if (get(key).isJsonNull) return null
        return get(key)?.asLong ?: get(key)?.asString?.toLongOrNull()
    } catch (ignore: Exception) {
        return this!!.get(key)?.asString?.toDoubleOrNull()?.toLong()
    } catch (ignore: Exception) {
        return null
    }
}

fun JsonObject?.longOrThrow(key: String): Long {
    return longOrNull(key) ?: throw JsonFieldNullException(key)
}

fun JsonObject?.long(key: String, default: Long = 0L): Long {
    return longOrNull(key) ?: default
}

fun JsonObject?.decimalOrNull(key: String): BigDecimal? {
    try {
        this ?: return null
        if (!has(key)) return null
        if (get(key).isJsonNull) return null
        return get(key)?.asBigDecimal ?: get(key)?.asString?.toBigDecimalOrNull()
        ?: null
    } catch (ignore: Exception) {
        return null
    }
}

fun JsonObject?.decimalOrThrow(key: String): BigDecimal {
    return decimalOrNull(key) ?: throw JsonFieldNullException(key)
}

fun JsonObject?.decimal(key: String, default: BigDecimal = BigDecimal.ZERO): BigDecimal {
    return decimalOrNull(key) ?: default
}

fun JsonObject?.floatOrNull(key: String): Float? {
    try {
        this ?: return null
        if (!has(key)) return null
        if (get(key).isJsonNull) return null
        return get(key)?.asFloat ?: get(key)?.asString?.toFloatOrNull() ?: null
    } catch (ignore: Exception) {
        return null
    }
}

fun JsonObject?.floatOrThrow(key: String): Float {
    return floatOrNull(key) ?: throw JsonFieldNullException(key)
}

fun JsonObject?.float(key: String, default: Float = 0f): Float {
    return floatOrNull(key) ?: default
}

fun JsonObject?.doubleOrNull(key: String): Double? {
    try {
        this ?: return null
        if (!has(key)) return null
        if (get(key).isJsonNull) return null
        return get(key)?.asDouble ?: get(key)?.asString?.toDoubleOrNull() ?: null
    } catch (ignore: Exception) {
        return null
    }
}

fun JsonObject?.doubleOrThrow(key: String): Double {
    return doubleOrNull(key) ?: throw JsonFieldNullException(key)
}

fun JsonObject?.double(key: String, default: Double = 0.0): Double {
    return doubleOrNull(key) ?: default
}

fun JsonObject?.dateOrNull(key: String, fmt: SimpleDateFormat): Date? {
    val s = this.str(key) ?: return null
    return try {
        fmt.parse(s)
    } catch (ignore: Exception) {
        return null
    }
}

fun JsonObject?.date(key: String, fmt: SimpleDateFormat): Date {
    return dateOrNull(key, fmt) ?: Date()
}

fun JsonObject?.dateOrThrow(key: String, fmt: SimpleDateFormat): Date {
    return dateOrNull(key, fmt) ?: throw JsonFieldNullException(key)
}

fun JsonObject?.list(key: String): List<JsonObject>? {
    val s = array(key).toString()
    return try {
        return convertFactory.fromJson(StringReader(s), Array<JsonObject>::class.java).toList()
    } catch (ignore: Exception) {
        null
    }
}

fun <T : Any> JsonObject?.list(key: String, cls: KClass<Array<T>>): List<T>? {
    val s = array(key).toString()
    return try {
        return convertFactory.fromJson(StringReader(s), cls.java).toList()
    } catch (ignore: Exception) {
        null
    }
}

fun JsonObject?.listString(key: String): List<String>? {
    val s = array(key).toString()
    return try {
        return convertFactory.fromJson(StringReader(s), Array<String>::class.java).toList()
    } catch (ignore: Exception) {
        null
    }
}

fun JsonObject?.listInt(key: String): List<Int>? {
    val s = array(key).toString()
    return try {
        return convertFactory.fromJson(StringReader(s), Array<Int>::class.java).toList()
    } catch (ignore: Exception) {
        null
    }
}

/**
 * Beauty json
 */
fun String?.stringyJson(): String {
    this ?: return "null"
    return try {
        JSONObject(this).toString(2)
    } catch (e: JSONException) {
        "null"
    }
}

fun JsonObject?.stringyJson(): String {
    this ?: return "null"
    return try {
        JSONObject(this.toString()).toString(2)
    } catch (e: JSONException) {
        "null"
    }
}