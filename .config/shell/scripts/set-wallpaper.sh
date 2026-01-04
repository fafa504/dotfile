#!/usr/bin/env sh

# Check if a wallpaper path was passed as an argument
if [ -n "$1" ]; then
    path_to_wallpaper=$(realpath "$1")
else
    read -p "Enter the full path to your wallpaper image: " path_to_wallpaper
fi

# Verify the file exists
if [ ! -f "$path_to_wallpaper" ]; then
    echo "Error: File not found at '$path_to_wallpaper'"
    exit 1
fi

script=$(
    cat <<EOF
desktops().forEach(d => {
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper","org.kde.image","General"];
    d.writeConfig("Image", "file://$path_to_wallpaper");
    d.reloadConfig();
});
EOF
)

# Send the script over DBus. Use qdbus6 if that's what your system has.
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$script"

echo "Wallpaper update script sent"
