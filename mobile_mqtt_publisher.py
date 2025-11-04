import paho.mqtt.client as mqtt
import time
import random
import json

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("✅ Підключено до MQTT брокера")
    else:
        print(f"❌ Помилка підключення: {rc}")

def on_publish(client, userdata, mid):
    print(f"📤 Повідомлення {mid} опубліковано")

def main():
    broker = "broker.hivemq.com"
    port = 1883
    topic = "weather/lviv/temperature"
    
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1, "mobile_tester")
    client.on_connect = on_connect
    client.on_publish = on_publish
    
    try:
        print("🔗 Підключення до MQTT брокера...")
        client.connect(broker, port, 60)
        client.loop_start()
        
        print("🌡️  Генерація тестових даних температури...")
        print("Натисніть Ctrl+C для зупинки")
        print("-" * 50)
        
        message_count = 0
        while True:
            # Генеруємо реалістичну температуру для Львова
            base_temp = 18  # Базова температура
            variation = random.uniform(-5, 5)  # Коливання ±5 градусів
            temperature = round(base_temp + variation, 1)
            
            message_count += 1
            
            # Публікуємо температуру
            result = client.publish(topic, f"{temperature}")
            
            if result.rc == mqtt.MQTT_ERR_SUCCESS:
                print(f"📊 [{message_count}] Температура у Львові: {temperature}°C")
                
                # Додаткові повідомлення для різних сценаріїв
                if message_count % 10 == 0:
                    print("   🎯 Тест стабільності з'єднання")
                elif temperature > 22:
                    print("   ☀️  Спекотний день у Львові")
                elif temperature < 15:
                    print("   ❄️  Прохолодний день у Львові")
                    
            else:
                print(f"❌ Помилка публікації: {result.rc}")
            
            time.sleep(5)  # Оновлюємо кожні 5 секунд
            
    except KeyboardInterrupt:
        print("\n🛑 Зупинка тестувальника...")
    except Exception as e:
        print(f"💥 Критична помилка: {e}")
    finally:
        client.loop_stop()
        client.disconnect()
        print("✅ Тестувальник зупинено")
        print(f"📈 Всього відправлено повідомлень: {message_count}")

if __name__ == "__main__":
    main()