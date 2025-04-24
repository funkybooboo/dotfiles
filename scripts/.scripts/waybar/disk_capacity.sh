#!/usr/bin/env bash

df -h / | grep -oP '\d+(?=%)'
