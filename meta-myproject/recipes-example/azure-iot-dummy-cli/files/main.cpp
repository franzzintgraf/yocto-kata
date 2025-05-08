#include <iostream>
#include <cstdlib>
#include <ctime>
#include <unistd.h>
#include <string>
#include <iothub.h>
#include <iothub_device_client.h>
#include <iothubtransportmqtt.h>
#include <iothub_client_options.h>

static const char* telemetry_template = "{\"temperature\":%d,\"humidity\":%d}";

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " \"<connection-string>\"" << std::endl;
        return 1;
    }

    std::string connStr = argv[1];

    if (IoTHub_Init() != 0) {
        std::cerr << "Failed to initialize IoTHub SDK." << std::endl;
        return 1;
    }

    IOTHUB_DEVICE_CLIENT_HANDLE device_handle = IoTHubDeviceClient_CreateFromConnectionString(connStr.c_str(), MQTT_Protocol);
    if (device_handle == nullptr) {
        std::cerr << "Failed to create device client handle." << std::endl;
        IoTHub_Deinit();
        return 1;
    }

    srand(static_cast<unsigned int>(time(nullptr)));

    for (int i = 0; i < 10; ++i) {
        int temp = 20 + rand() % 10;
        int hum = 40 + rand() % 20;

        char payload[64];
        snprintf(payload, sizeof(payload), telemetry_template, temp, hum);

        IOTHUB_MESSAGE_HANDLE message = IoTHubMessage_CreateFromString(payload);
        if (message == nullptr) {
            std::cerr << "Failed to create IoTHub message." << std::endl;
            continue;
        }

        if (IoTHubDeviceClient_SendEventAsync(device_handle, message, nullptr, nullptr) != IOTHUB_CLIENT_OK) {
            std::cerr << "Failed to send message." << std::endl;
        } else {
            std::cout << "Sent: " << payload << std::endl;
        }

        IoTHubMessage_Destroy(message);
        sleep(5);
    }

    IoTHubDeviceClient_Destroy(device_handle);
    IoTHub_Deinit();

    return 0;
}