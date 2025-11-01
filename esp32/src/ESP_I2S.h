// ESP_I2S.h - Basic I2S implementation for ESP32
#ifndef ESP_I2S_H
#define ESP_I2S_H

#include <Arduino.h>
#include <driver/i2s.h>

// I2S pin definitions
#define I2S_MIC_CLOCK_PIN 42
#define I2S_MIC_DATA_PIN  41
#define I2S_SPK_BCLK 7
#define I2S_SPK_LRCK 8
#define I2S_SPK_DIN  9

class I2SClass {
public:
    I2SClass() {}
    
    // PDM RX methods
    void setPinsPdmRx(int clockPin, int dataPin) {
        // Store pin configuration for PDM RX
        micClockPin = clockPin;
        micDataPin = dataPin;
    }
    
    bool begin(i2s_mode_t mode, int sampleRate, i2s_bits_per_sample_t bits, i2s_channel_t channel) {
        // Configure I2S peripheral
        i2s_config_t i2s_config = {
            .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_RX),
            .sample_rate = (uint32_t)sampleRate,
            .bits_per_sample = bits,
            .channel_format = (i2s_channel_fmt_t)I2S_CHANNEL_FMT_ONLY_LEFT,  // 默认单声道
            .communication_format = I2S_COMM_FORMAT_STAND_I2S,
            .intr_alloc_flags = 0,
            .dma_buf_count = 8,
            .dma_buf_len = 64,
            .use_apll = false,
            .tx_desc_auto_clear = false,
            .fixed_mclk = 0,
            .mclk_multiple = I2S_MCLK_MULTIPLE_DEFAULT,
            .bits_per_chan = (i2s_bits_per_chan_t)bits
        };
        
        i2s_pin_config_t pin_config = {
            .mck_io_num = I2S_PIN_NO_CHANGE,
            .bck_io_num = I2S_PIN_NO_CHANGE,
            .ws_io_num = micClockPin,
            .data_out_num = I2S_PIN_NO_CHANGE,
            .data_in_num = micDataPin
        };
        
        esp_err_t err = i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
        if (err != ESP_OK) {
            Serial.printf("I2S driver install failed: %d\n", err);
            return false;
        }
        
        err = i2s_set_pin(I2S_NUM_0, &pin_config);
        if (err != ESP_OK) {
            Serial.printf("I2S set pin failed: %d\n", err);
            return false;
        }
        
        return true;
    }
    
    int read() {
        size_t bytes_read;
        int16_t sample;
        esp_err_t err = i2s_read(I2S_NUM_0, &sample, sizeof(sample), &bytes_read, portMAX_DELAY);
        if (err == ESP_OK && bytes_read == sizeof(sample)) {
            return sample;
        }
        return -1;
    }
    
    // Standard TX methods
    void setPins(int bclk, int lrck, int din) {
        // Store pin configuration for standard TX
        spkBclkPin = bclk;
        spkLrckPin = lrck;
        spkDinPin = din;
    }
    
    size_t write(const uint8_t* data, size_t len) {
        size_t bytes_written;
        esp_err_t err = i2s_write(I2S_NUM_0, data, len, &bytes_written, portMAX_DELAY);
        if (err != ESP_OK) {
            Serial.printf("I2S write failed: %d\n", err);
            return 0;
        }
        return bytes_written;
    }
    
private:
    int micClockPin = I2S_MIC_CLOCK_PIN;
    int micDataPin = I2S_MIC_DATA_PIN;
    int spkBclkPin = I2S_SPK_BCLK;
    int spkLrckPin = I2S_SPK_LRCK;
    int spkDinPin = I2S_SPK_DIN;
};

#endif // ESP_I2S_H