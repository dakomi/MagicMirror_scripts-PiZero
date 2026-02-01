#!/usr/bin/env python3
"""
MagicMirror Python WebKit2 Browser
A lightweight browser for displaying MagicMirror on low-memory devices

Usage:
    DISPLAY=:0 python3 mm-browser.py [URL]

If no URL is provided, defaults to http://localhost:8080

Credits:
- Original solution by MerlinElMago for Pi Zero W (256MB RAM)
  https://forum.magicmirror.builders/topic/18200/mm-on-a-raspberry-zero-w-in-2023
- Adapted for Pi Zero 2W (512MB RAM)

Requirements:
    sudo apt-get install -y gir1.2-webkit2-4.1 libgtk-3-dev libwebkit2gtk-4.1-dev python3-gi
"""

import sys
import gi

gi.require_version("Gtk", "3.0")
gi.require_version("WebKit2", "4.1")
from gi.repository import Gtk, WebKit2


class Minibrowser(Gtk.Window):
    """Minimal fullscreen browser for MagicMirror display"""
    
    def __init__(self, url="http://localhost:8080"):
        Gtk.Window.__init__(self, title="MagicMirror²")
        self.set_default_size(800, 600)
        
        # Create WebKit2 view
        web_view = WebKit2.WebView()
        web_view.load_uri(url)
        
        # Add scrolled window (required for WebKit2)
        scrolled_window = Gtk.ScrolledWindow()
        scrolled_window.add(web_view)
        self.add(scrolled_window)
        
        # Go fullscreen
        self.fullscreen()


if __name__ == "__main__":
    # Get URL from command line or use default
    url = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8080"
    
    # Create and show window
    win = Minibrowser(url)
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    
    # Start GTK main loop
    Gtk.main()
