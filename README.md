# GPIO-pca9548
 
### Note: -- This overlay currently is experimental with the BUSTER release of Raspian --
Adapt PCA9548 multiplexer overlay to GPIO I2C bus for Raspberry Pi 4 and the BUSTER release of Raspian.  
### The shell script is tested on the following -
    Raspberry Pi 4B v1.2  Buster 2/23/2020
    Raspberry Pi 3b+ v1.3 Stretch Debian version 9.11
    
This is most useful for devices that are SMbus compliant (<=100khz clock) or have fixed addresses that prevent using more than one of the same device on the same bus. This is also a good work-around on the Raspberry Pi for the clock-stretching bug that some devices (AM2315 for instance) misbehave with the clock artifacts from the hardware ARM I2C bus. Control the clock speed by modifying the delay ( i2c_gpio_delay_us ).  This software bus provides some additional SMbus support.

For details on the SMbus functions: [https://www.kernel.org/doc/Documentation/i2c/smbus-protocol]

### I2C-ARM 

        pi@raspberry:~ $ sudo i2cdetect -F 1
        Functionalities implemented by /dev/i2c-1:
        I2C                              yes
        SMBus Quick Command              yes
        SMBus Send Byte                  yes
        SMBus Receive Byte               yes
        SMBus Write Byte                 yes
        SMBus Read Byte                  yes
        SMBus Write Word                 yes
        SMBus Read Word                  yes
        SMBus Process Call               yes
        SMBus Block Write                yes
        SMBus Block Read                 no
        SMBus Block Process Call         no
        SMBus PEC                        yes
        I2C Block Write                  yes
        I2C Block Read                   yes



### Software-I2C


         pi@raspberry:~ $ sudo i2cdetect -F 3
         Functionalities implemented by /dev/i2c-3:
         I2C                              yes
         SMBus Quick Command              yes
         SMBus Send Byte                  yes
         SMBus Receive Byte               yes
         SMBus Write Byte                 yes
         SMBus Read Byte                  yes
         SMBus Write Word                 yes
         SMBus Read Word                  yes
         SMBus Process Call               yes
         SMBus Block Write                yes
         SMBus Block Read                 yes
         SMBus Block Process Call         yes
         SMBus PEC                        yes
         I2C Block Write                  yes
         I2C Block Read                   yes



The standard overlay only looks on the hardware ARM I2C bus for the mux. This overlay adds additional bus entries in /dev for the mux channels on a software (GPIO) I2C bus configured by the install script:

### i2c-gpio i2c@0: using pins 23 (SDA) and 24 (SCL)


You can check for new devices with 'sudo i2cdetect -y BUS' ( BUS is an integer for the bus to scan )


You should be able to access devices with any code that can use the /dev/i2c-X device to address i2c devices on that bus. The RESET line on the PCA9548 would need code and a GPIO pin to clear hung devices. Reset cannot be implemented in the overlay.

/dev/i2c-3   This is the software GPIO i2c bus

/dev/i2c-4    This is the first mux i2c channel

/dev/i2c-5    This is the second mux i2c channel

..   (other channels)

## To Install with the defaults. 
## This is the best method if you don't want to manually edit files.

### Step 1 - Change to /home/pi and Download the install script

pi@raspberry:~ cd ~

pi@raspberry:~ wget https://raw.githubusercontent.com/Theoi-Meteoroi/GPIO-pca9548/master/mux-install.sh

### Step 2 - Run the install script

pi@raspberry:~ /bin/bash mux-install.sh

### Step 3 -  Reboot

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


You can also list out the configured I2C bus instances with

### pi@raspberry:~ sudo i2cdetect -l

# Debugging I2C bus problems

This is a good reference for general issues:

[https://www.i2c-bus.org/i2c-primer/common-problems/]



## Manual install instructions:

### 1. Change directory to /home/pi and copy the source and build a dtbo 

cd ~

wget https://raw.githubusercontent.com/Theoi-Meteoroi/GPIO-pca9548/master/i2c_gpio-pca9548.dts

sudo dtc -W no-unit_address_vs_reg -I dts -O dtb -@ -o /boot/overlays/i2c_gpio-pca9548.dtbo ./i2c_gpio-pca9548.dts

### 2. Now, edit /boot/config.txt with the following command:

vi /boot/config.txt

### 3. Go to the end of the file and add the following two lines:

---
dtoverlay=i2c-gpio,i2c_gpio_sda=23,i2c_gpio_scl=24,i2c_gpio_delay_us=4
dtoverlay=i2c_gpio-pca9548
---
### 4. SAVE your edits in vi, exit vi. 

# Build your own or buy

You will need to have your multiplexer connected with SDA on pin 23 and SCL on pin 24.  Use the +3.3v to power the pca9548.  Add a 10uf tantalum capacitor near the device if possible to provide for transient spikes. Remember to tie the /RESET pin to +3.3v through a pull-up resistor.  The GPIO lines also need a nominal pull-up to 3.3v. 4.7k ohm seems to work well because the Pi pins are capable of sinking a max of 16mA, but be aware the SMbus specification for minimum sink current of 100µA, and a maximum of 350µA, compared to 3mA for the I²C bus.  This in turn would determine the lowest acceptable value of the pullup resistor, examples of which are shown in the table below.  This will matter for stability of the attached SMbus devices.

##  Minimum Pullup Resistor Values per Bus Specifications
	
 |    | 3V VDD | 5V VDD |
 |----|-----|------|
 | I²C Bus | > 1k | > 1.6k |
 | SMBus | > 8.5k | > 14k  |


Address lines should also be connected to GND or +3.3v, either directly or through a pull-up resistor (10k or so is fine.)

If you have it properly connected and powered, after rebooting you will have several new I2C buses available for use, one for each channel of the multiplexer. You can verify the buses are available by going to the Config -> System Information page of Mycodo and viewing the I2C buses. If there's only one, there is an issue. If you see 9 buses (1 from the original bus + 8 new buses from the multiplexer), then everything is working and you can begin connecting devices to your multiplexer channels.

## tested compatible product

DFRobot DFR0576 PCA9548 Mux breakout - I have tested this board. Comes with a cable that can directly connect to the GPIO pins.  At the moment the board sells for US $6.90 which is less than most other breakouts that need alot of work to connect. This board can be up and working with your pi in less than 10 minutes, including installing the mux overlay. 
[https://www.dfrobot.com/wiki/index.php/Gravity:_Digital_1-to-8_I2C_Multiplexer_SKU:DFR0576]  

