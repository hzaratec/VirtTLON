import cmd
import os
import random
import math


def do_adhoc():
		"Run a shell command"
		os.system('pwd')
		# CONFIGURACION DE LA RED AD HOC MODO BATMAN- INICADO POR EL USUARIO.
		os.system('sudo modprobe batman-adv')
		os.system('sudo ifconfig wlan0 down')
		os.system('sudo iwconfig wlan0 mode ad-hoc')
		os.system('sudo ifconfig wlan0 mtu 1532')
		os.system('sudo iwconfig wlan0 mode ad-hoc essid TLONadhoc ap 02:1B:55:AD:0C:02 channel 4')
		os.system('sudo sleep 1')
		os.system('sudo ip link set wlan0 up')
		os.system('sudo sleep 1')
		os.system('sudo batctl if add wlan0')
		os.system('sudo ifconfig bat0 up')
		os.system('sudo avahi-autoipd -D bat0')

do_adhoc();

