# GPIO-pca9548
Adapt PCA9548 mux to GPIO I2C bus for Raspberry Pi 
Only looks on a GPIO software I2C bus for the mux.
Adds additional bus entries in /dev:

/dev/i2c-3   This is the software GPIO i2c bus

/dev/i2c-4   This is the first mux i2c channel

/dev/i2c-5   this is the second mux i2c channel

..   (other channels)

To Install - 

sudo dtc -I dts -O dtb -@ -o /boot/overlays/i2c_gpio-pca9548.dtbo i2c_gpio-pca9548.dts

In /boot/config.txt add these two lines

dtoverlay=i2c-gpio,i2c_gpio_sda=23,i2c_gpio_scl=24,i2c_gpio_delay_us=4

dtoverlay=i2c_gpio-pca9548
