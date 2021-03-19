#!/bin/bash

## i3 dot
ln -s `pwd`/i3 $HOME/.config/i3

## rofi
ln -s `pwd`/rofi $HOME/.config/rofi

## xfce4 terminal theme
sudo ln -s `pwd`/onedark.theme /usr/share/xfce4/terminal/colorschemes/onedark.theme

## gtkrc
ln -s `pwd`/gtkrc-2.0 $HOME/.gtkrc-2.0
