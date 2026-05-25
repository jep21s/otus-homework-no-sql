@file:DependsOn("org.apache.kafka:kafka-clients:4.0.0")
@file:DependsOn("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.9.0")

import kotlinx.coroutines.*
import org.apache.kafka.clients.producer.KafkaProducer
import org.apache.kafka.clients.producer.ProducerRecord
import org.apache.kafka.clients.consumer.KafkaConsumer
import org.apache.kafka.clients.consumer.ConsumerRecords
import org.apache.kafka.common.serialization.StringSerializer
import org.apache.kafka.common.serialization.StringDeserializer
import java.time.Duration
import java.util.*

val topic = "test"
val bootstrapServers = "localhost:9092"

val producerProps = Properties().apply {
    put("bootstrap.servers", bootstrapServers)
    put("key.serializer", StringSerializer::class.java.name)
    put("value.serializer", StringSerializer::class.java.name)
}

val consumerProps = Properties().apply {
    put("bootstrap.servers", bootstrapServers)
    put("group.id", "kotlin-consumer-${UUID.randomUUID()}")
    put("auto.offset.reset", "earliest")
    put("key.deserializer", StringDeserializer::class.java.name)
    put("value.deserializer", StringDeserializer::class.java.name)
}

runBlocking {
    val job = coroutineContext[Job]!!
    Runtime.getRuntime().addShutdownHook(Thread(Runnable { job.cancel() }))

    launch(Dispatchers.Default) {
        val producer = KafkaProducer<String, String>(producerProps)
        var counter = 0
        try {
            while (isActive) {
                val value = "message-$counter"
                producer.send(ProducerRecord(topic, "key-$counter", value))
                println("[Producer] Sent: $value")
                counter++
                delay(1000)
            }
        } finally {
            producer.close()
            println("[Producer] Closed")
        }
    }

    launch(Dispatchers.Default) {
        val consumer = KafkaConsumer<String, String>(consumerProps)
        consumer.subscribe(listOf(topic))
        try {
            while (isActive) {
                val records = consumer.poll(Duration.ofMillis(500))
                records.forEach { record ->
                    println("[Consumer] Received: key=${record.key()}, value=${record.value()}, offset=${record.offset()}")
                }
            }
        } finally {
            consumer.close()
            println("[Consumer] Closed")
        }
    }
}
