#!/bin/sh
niri msg keyboard-layouts | grep '*' | sed -E 's/.*\* [0-9]+ //'
