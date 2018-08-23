# GPIO-pca9548

Adapt PCA9548 mux to GPIO I2C bus for Raspberry Pi

The standard overlay only looks on the hardware ARM I2C bus for the mux.

This overlay adds additional bus entries in /dev for the mux channels. 

You can check for new devices with 'sudo i2cdetect -y BUS' 

You should be able to access devices with any code that can use the /dev/i2c-X device to address
i2c devices on that bus. The RESET line would need code and a GPIO pin to clear hung devices.

/dev/i2c-3   This is the software GPIO i2c bus

/dev/i2c-4    This is the first mux i2c channel

/dev/i2c-5    This is the second mux i2c channel

..   (other channels)

To Install - 

sudo dtc -I dts -O dtb -@ -o /boot/overlays/i2c_gpio-pca9548.dtbo i2c_gpio-pca9548.dts

In /boot/config.txt add these two lines. You can use other suitable GPIO pins for SCL and SDA (tested)

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


This is with the default i2c address of 0x70.  You can pass another address in the declaration:

dtoverlay=i2c_gpio-pca9548,addr=0x71



User friendly install instructions:

1. Change directory to /home/pi and copy the source and build a dtbo 
----
cd ~
----
wget https://raw.githubusercontent.com/Theoi-Meteoroi/GPIO-pca9548/master/i2c_gpio-pca9548.dts
----
sudo dtc -I dts -O dtb -@ -o /boot/overlays/i2c_gpio-pca9548.dtbo ./i2c_gpio-pca9548.dts
----
2. Now, edit /boot/config.txt with the following command:
----
vi /boot/config.txt
----
 3. Go to the end of the file and add the following two lines:
----
dtoverlay=i2c-gpio,i2c_gpio_sda=23,i2c_gpio_scl=24,i2c_gpio_delay_us=4
dtoverlay=i2c_gpio-pca9548
----
 4. SAVE your edits in vi, exit vi. 


You will need to have your multiplexer connected with SDA on pin 23 and SCL on pin 24.  Use the +3.3v to power the pca9548.  Add a 10uf tantalum capacitor near the device if possible to provide for transient spikes. Remember to tie the /RESET pin to +3.3v either directly or through a pull-up resistor.  The GPIO lines also need a nominal pull-up to 3.3v. 4.7k ohm seems to work well.  Address lines should also be connected to GND or +3.3v, either directly or through a pull-up resistor (10k or so is fine.)

If you have it properly connected and powered, after rebooting you will have several new I2C buses available for use, one for each channel of the multiplexer. You can verify the buses are available by going to the Config -> System Information page of Mycodo and viewing the I2C buses. If there's only one, there is an issue. If you see 9 buses (1 from the original bus + 8 new buses from the multiplexer), then everything is working and you can begin connecting devices to your multiplexer channels.



