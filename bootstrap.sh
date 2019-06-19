#!/bin/bash

# Copyright (C) 2019 Intel Corporation
# SPDX-License-Identifier: BSD-3-Clause

source /opt/bootstrap/functions

# Bug fix for install
mkdir /dev/sr0

# Detect HDD
if [ -d /sys/block/[vsdh]da ]; then
    DRIVE=$(echo /dev/`ls -l /sys/block/[vsdh]da | grep -v usb | head -n1 | sed 's/^.*\([vsd]d[a-z]\+\).*$/\1/'`);
        run "Installing RancherOS on drive ${DRIVE}" \
            "sudo ros install --force -d ${DRIVE} --append 'rancher.password=P@ssw0rd!'" \
            "/tmp/provisioning.log"
else
    DRIVE=$(echo /dev/`ls -l /sys/block/nvme* | grep -v usb | head -n1 | sed 's/^.*\(nvme[a-z0-1]\+\).*$/\1/'`);
        PARTITION=${DRIVE}p1;
        run "Installing RancherOS on drive ${DRIVE} and partition ${PARTITION}" \
            "sudo ros install --force -d ${DRIVE} -p ${PARTITION} --append 'rancher.password=P@ssw0rd!'" \
            "/tmp/provisioning.log"
fi
