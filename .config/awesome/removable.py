#!/usr/bin/python2
# -*- coding: utf8 -*-

import dbus

bus = dbus.SystemBus()
udisks = bus.get_object("org.freedesktop.UDisks", "/org/freedesktop/UDisks")
udisks_iface = dbus.Interface(udisks, 'org.freedesktop.UDisks')

for device in udisks_iface.EnumerateDevices():
    dev = bus.get_object("org.freedesktop.UDisks", device)
    dev_iface = dbus.Interface(dev, dbus.PROPERTIES_IFACE)
    device_file = dev_iface.Get('org.freedesktop.UDisks.Device', "DeviceFile")
    has_media = dev_iface.Get('org.freedesktop.UDisks.Device', "DeviceIsMediaAvailable")
    mount_paths = dev_iface.Get('org.freedesktop.UDisks.Device', "DeviceMountPaths")
    has_partitiontable = dev_iface.Get('org.freedesktop.UDisks.Device', "DeviceIsPartitionTable")
    is_internal = dev_iface.Get('org.freedesktop.UDisks.Device', "DeviceIsSystemInternal")
    is_optical = dev_iface.Get('org.freedesktop.UDisks.Device', "DeviceIsOpticalDisc")
    if not is_internal and not has_partitiontable and has_media:
        if mount_paths:
            print "mount", device_file, ("Optical" if is_optical else "USB"), mount_paths[0]
        else:
            print "unmount", device_file, ("Optical" if is_optical else "USB")
 
