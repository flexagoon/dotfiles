#!/bin/sh
systemctl enable --user --now kmonad
systemctl enable --user --now awatcher
systemctl enable --user --now autorestic.timer
