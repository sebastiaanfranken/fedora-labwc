# fedora-labwc
Repository to transform a minimal Fedora install to something more beautiful with LabWC

![Screenshot](https://github.com/sebastiaanfranken/fedora-labwc/raw/main/meta/screenshot.png)

## Keyboard shortcuts
A quick overview of some of the (custom) keyboard shortcuts. For a complete list (and more), see the `~/.config/labwc/rc.xml` file.

| Hotkey(s) | Action |
|-----------|--------|
| *Super* + *Return* | Opens the terminal application (Foot) |
| *Alt* + *F3* | Opens the menu launcher (bemenu-run) |
| *Super* + *d* | Opens the menu laucher (bemenu-run) |
| *Super* + *l* (lower case L) | Locks the screen (swaylock) |
| *Super* + *left arrow* | Snaps the active window to the left of the screen |
| *Super* + *right arrow* | Snaps the active window to the right of the screen |
| *Super* + *up arrow* | Maximizes the active window |
| *Super* + *down arrow* | Restores the active window size |
| *Control* + *Alt* + *left arrow* | Switch to the desktop left of current one |
| *Control* + *Alt* + *right arrow* | Switch to the desktop right of current one | 
| *Control* + *Shift* + *Alt* + *left arrow* | Switch to the desktop left of the current one and transport current application |
| *Control* + *Shift* + *Alt* + *right arrow* | Switch to the desktop right of the current one and transport current application |

## Configuration
To configure this tool to ignore certain configuration files create a new file at `~/.config/fedora-labwc-ignore-files.conf` and put the
filename you want to ignore in it, one filename per line. For example, to ignore the user configuration file for the foot terminal add the following to `~/.config/fedora-labwc-ignore-files.conf`:

```
~/.config/foot/foot.ini
```

The next time `install.sh` is called it will ignore the `~/.config/foot/foot.ini` file and move on to the next file.
