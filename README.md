# GPIO-pca9548

Adapt PCA9548 mux to GPIO I2C bus for Raspberry Pi

The standard overlay only looks on a GPIO software I2C bus for the mux.

This overlay adds additional bus entries in /dev for the mux channels

/dev/i2c-3   This is the software GPIO i2c bus

/dev/i2c-4    This is the first mux i2c channel

/dev/i2c-5    This is the second mux i2c channel

..   (other channels)

To Install - 

sudo dtc -I dts -O dtb -@ -o /boot/overlays/i2c_gpio-pca9548.dtbo i2c_gpio-pca9548.dts

In /boot/config.txt add these two lines

dtoverlay=i2c-gpio,i2c_gpio_sda=23,i2c_gpio_scl=24,i2c_gpio_delay_us=4

dtoverlay=i2c_gpio-pca9548


After reboot, you should see something like this in dmesg output:

[    2.168710] systemd-udevd[137]: starting version 215

[    2.527337] i2c-gpio i2c@0: using pins 23 (SDA) and 24 (SCL)

[    2.796954] i2c i2c-3: Added multiplexed i2c bus 4

[    2.799319] i2c i2c-3: Added multiplexed i2c bus 5

[    2.801690] i2c i2c-3: Added multiplexed i2c bus 6

[    2.803925] i2c i2c-3: Added multiplexed i2c bus 7

[    2.808755] i2c i2c-3: Added multiplexed i2c bus 8

[    2.809316] i2c i2c-3: Added multiplexed i2c bus 9

[    2.811035] i2c i2c-3: Added multiplexed i2c bus 10

[    2.812586] i2c i2c-3: Added multiplexed i2c bus 11

[    2.812604] pca954x 3-0070: registered 8 multiplexed busses for I2C switch pca9548

