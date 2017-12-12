# GPIO-pca9548
Adapt PCA9548 mux to GPIO I2C bus for Raspberry Pi 
Only looks on a GPIO software I2C bus for the mux.

To Install - 

sudo dtc -I dts -O dtb -@ -o /boot/overlays/i2c-pca9548.dtbo i2c-pca9548.dts

In /boot/config.txt

dtoverlay=i2c-gpio,i2c_gpio_sda=23,i2c_gpio_scl=24,i2c_gpio_delay_us=4
dtoverlay=i2c-pca9548
