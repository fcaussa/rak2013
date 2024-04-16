# rak2013
RAKWireless RAK2013 Pi Hat LTE

This is a script to enable Rak2013 Pi Hat on Raspberry Pi SbC

It had to be updated due to hardware changes on GPIO managment;

First we need to identify the chips that handles respective GPIO

running 

```bash
ls /sys/class/gpio/
```
we will get an OUTPUT similar to this

```bash
export  gpiochip512  gpiochip570  unexport
```

This shows us that there are 2 chips that handle all GPIOS

using gpioinfo
```bash
#apt install gpiod
gpioinfo

gpiochip0 - 58 lines: 
        line   0:     "ID_SDA"       unused   input  active-high
        line   1:     "ID_SCL"       unused   input  active-high
        line   2:      "GPIO2"       unused   input  active-high
        line   3:      "GPIO3"       unused   input  active-high
        line   4:      "GPIO4"       unused   input  active-high
        line   5:      "GPIO5"       unused   input  active-high
        line   6:      "GPIO6"       unused   input  active-high
        line   7:      "GPIO7"       unused   input  active-high
        line   8:      "GPIO8"       unused   input  active-high
        line   9:      "GPIO9"       unused   input  active-high
        line  10:     "GPIO10"       unused   input  active-high
        line  11:     "GPIO11"       unused   input  active-high
        line  12:     "GPIO12"       unused   input  active-high
        line  13:     "GPIO13"       unused   input  active-high
        line  14:     "GPIO14"       unused   input  active-high
        line  15:     "GPIO15"       unused   input  active-high
        line  16:     "GPIO16"       unused   input  active-high
        line  17:     "GPIO17"       unused   input  active-high
        line  18:     "GPIO18"       unused   input  active-high
        line  19:     "GPIO19"       unused   input  active-high
        line  20:     "GPIO20"       unused   input  active-high
        line  21:     "GPIO21"       unused   input  active-high
        line  22:     "GPIO22"       unused   input  active-high
        line  23:     "GPIO23"       unused   input  active-high
        line  24:     "GPIO24"       unused   input  active-high
        line  25:     "GPIO25"       unused   input  active-high
        line  26:     "GPIO26"       unused   input  active-high
        line  27:     "GPIO27"       unused   input  active-high
        line  28: "RGMII_MDIO"       unused   input  active-high
        line  29:  "RGMIO_MDC"       unused   input  active-high
        line  30:       "CTS0"       unused   input  active-high
        line  31:       "RTS0"       unused   input  active-high
        line  32:       "TXD0"       unused   input  active-high
        line  33:       "RXD0"       unused   input  active-high
        line  34:    "SD1_CLK"       unused   input  active-high
        line  35:    "SD1_CMD"       unused   input  active-high
        line  36:  "SD1_DATA0"       unused   input  active-high
        line  37:  "SD1_DATA1"       unused   input  active-high
        line  38:  "SD1_DATA2"       unused   input  active-high
        line  39:  "SD1_DATA3"       unused   input  active-high
        line  40:  "PWM0_MISO"       unused   input  active-high
        line  41:  "PWM1_MOSI"       unused   input  active-high
        line  42: "STATUS_LED_G_CLK" "ACT" output active-high [used]
        line  43: "SPIFLASH_CE_N" unused input active-high
        line  44:       "SDA0"       unused   input  active-high
        line  45:       "SCL0"       unused   input  active-high
        line  46: "RGMII_RXCLK" unused input active-high
        line  47: "RGMII_RXCTL" unused input active-high
        line  48: "RGMII_RXD0"       unused   input  active-high
        line  49: "RGMII_RXD1"       unused   input  active-high
        line  50: "RGMII_RXD2"       unused   input  active-high
        line  51: "RGMII_RXD3"       unused   input  active-high
        line  52: "RGMII_TXCLK" unused input active-high
        line  53: "RGMII_TXCTL" unused input active-high
        line  54: "RGMII_TXD0"       unused   input  active-high
        line  55: "RGMII_TXD1"       unused   input  active-high
        line  56: "RGMII_TXD2"       unused   input  active-high
        line  57: "RGMII_TXD3"       unused   input  active-high
gpiochip1 - 8 lines:
        line   0:      "BT_ON"   "shutdown"  output  active-high [used]
        line   1:      "WL_ON"       unused  output  active-high
        line   2: "PWR_LED_OFF" "PWR" output active-low [used]
        line   3: "GLOBAL_RESET" unused output active-high
        line   4: "VDD_SD_IO_SEL" "vdd-sd-io" output active-high [used]
        line   5:   "CAM_GPIO" "cam1_regulator" output active-high [used]
        line   6:  "SD_PWR_ON" "regulator-sd-vcc" output active-high [used]
        line   7:    "SD_OC_N"       unused   input  active-high

```

gpiochp0 is gpiochip512 and gpiochip1 is gpio570

With this information, now we can handle the GPIOs from BASH, adding the number of the chip to the corresponding GPIO

For the Rak2013 we need to handle GPIOs 5,6,13,19,21 and 26 in order to Power on the hat.

Controller is gpio512

inputs must be 512 + pin number

GPIO PIN->   ChipPIN
```bash
5     ->   517
6     ->   518
13    ->   525
18    ->   530 (Power Enable) 
19    ->   531
21    ->   533
26    ->   538
```
Now we need to adjust the activate_lte script with respective GPIO Pins.

Now we run install
```bash
#modify accordingly

#sudo ./install.sh 'internet.movil' /dev/ttyS0 115200
sudo ./install.sh <apn> <serialport> <baudrate>



```

and after is completed!

we can execute activate_lte.

This will turn ON the Rak2013 LTE hat, create a ppp0 link (connection) and set the default route to it.

You can add a crontab @reboot to be executed at reboot, Or you can mannually run it every time you want to connect to the LTE APN

```bash
@reboot sleep 60 && /path/to/folder/rak2013/activate_lte 2>/dev/null &
```

Reboot the Rpi, and it should automatically turn on the LTE hat, (Blue Light) and Connect (red light) to the LTE network

Done!



