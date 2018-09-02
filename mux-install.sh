#!/bin/sh -e
#
#  mux-install.sh
#
# GPL v3.0 License 
# 8/22/2018  D.Thompson
#
#  build and install dtbo from dts
#  Add Software I2C overlay using:
#  SDA - GPIO 23  header pin 16
#  SCL - GPIO 24  header pin 18
#  4 uSec delay for approx 100khz
#
#  Add the i2c_gpio-pca9548 overlay to /boot/config.txt at default address 0x70
#  
#
# Change directory to /home/pi
cd ~
#
# Get a copy of the .dts file from github
wget https://raw.githubusercontent.com/Theoi-Meteoroi/GPIO-pca9548/master/i2c_gpio-pca9548.dts
echo
echo
#
# Create the overlay file and put in /boot/overlays
sudo dtc -I dts -O dtb -@ -o /boot/overlays/i2c_gpio-pca9548.dtbo ./i2c_gpio-pca9548.dts
echo
#
# Put the required changes into /boot/config.txt
sudo sh -c "echo '# Add software i2c and pca9548 mux support' >> /boot/config.txt"
sudo sh -c "echo 'dtoverlay=i2c-gpio,i2c_gpio_sda=23,i2c_gpio_scl=24,i2c_gpio_delay_us=4' >> /boot/config.txt"
sudo sh -c "echo 'dtoverlay=i2c_gpio-pca9548,addr=0x70' >> /boot/config.txt"
#
#
echo
echo
echo "Please reboot to complete installation"

