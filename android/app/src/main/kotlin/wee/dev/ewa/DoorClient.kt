package wee.dev.ewa

import com.google.gson.JsonObject
import okhttp3.OkHttpClient
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.Url
import java.util.concurrent.TimeUnit

interface DoorService {
    @POST
    fun request(@Url url: String?, @Body body: JsonObject): Call<JsonObject>
}

val doorService = Retrofit.Builder()
    .addConverterFactory(GsonConverterFactory.create())
    .baseUrl("www.google.com/")
    .client(
        OkHttpClient.Builder()
            .connectTimeout(10000, TimeUnit.MILLISECONDS)
            .build()
    )
    .build()
    .create(DoorService::class.java)
