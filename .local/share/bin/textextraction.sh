if [ ! -f /tmp/my_command.lock ]; then
    touch /tmp/my_command.lock
    grim -g "$(slurp)" - | tesseract stdin stdout -l eng | wl-copy
    rm /tmp/my_command.lock
fi
