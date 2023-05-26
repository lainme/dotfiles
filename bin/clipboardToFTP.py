#!/usr/bin/env python3
import os
import sys
import ftplib
import keyring
import tkinter
import tkinter.messagebox
from io import BytesIO
from PIL import Image
import chardet
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GdkPixbuf
import configparser
import argparse

def show_message(msg):
    root = tkinter.Tk()
    root.withdraw()
    tkinter.messagebox.showinfo("clipboardToFTP", msg)

def upload_to_ftp(host, username, password, active, local_path, remote_path):
    try:
        # Connect to FTP via active mode
        ftp = ftplib.FTP()
        if active:
            ftp.set_pasv(False)
        ftp.connect(host)
        ftp.login(username, password)
        # Upload file
        with open(local_path, 'rb') as file:
            ftp.storbinary(f'STOR {remote_path}', file)
        show_message('Upload successful')
    except Exception as e:
        show_message(f'Error uploading file to FTP server: {e}')
        sys.exit(1)
    finally:
        ftp.quit()

def get_clipboard_content():
    # Create clipboard
    clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)

    # Obtain image or text data
    clipboard_data = clipboard.wait_for_image()
    if clipboard_data is None or clipboard_data.get_formats() is None:
        clipboard_data = clipboard.wait_for_text()
        if clipboard_data is None:
            show_message('Clipboard does not contain an image or text')
            sys.exit(1)
        else:
            return clipboard_data, 'txt'
    else:
        return clipboard_data, 'img'

if __name__ == '__main__':
    # Construct command line arguments
    parser = argparse.ArgumentParser(description='Upload clipboard content to FTP server')
    parser.add_argument('--config', default=None, help='Path to the configuration file')
    parser.add_argument('--host', default=None, help='FTP server hostname or IP')
    parser.add_argument('--username', default=None, help='Username')
    parser.add_argument('--password', default=None, help='Password')
    parser.add_argument('--keyring', action='store_true', help='Use keyring to obtain password')
    parser.add_argument('--active', action='store_true', help='Enable active mode for FTP')
    parser.add_argument('--remote', default='/', help='Remote directory for upload')

    # Parse command line arguments
    args = parser.parse_args()
    if args.config:
        try:
            # Read from configuration file
            config = configparser.ConfigParser({'keyring': False, 'active': False, 'remote': '/'})
            config.read(args.config)
            host = config.get("Server", "host")
            username = config.get("Server", "username")
            if config.get("Server", "keyring"):
                password = keyring.get_password(host, username)
            else:
                password = config.get("Server", "password")
            active = config.get("Server", "active")
            remote = config.get("Server", "remote")
        except Exception as e:
            print(f"Error: {str(e)}")
            sys.exit(1)
    else:
        host = args.host
        username = args.username
        password = args.password
        active = args.active
        remote = args.remote
        if host == None:
            print("Error: host must be supplied")
            sys.exit(1)
        if username == None:
            print("Error: username must be supplied")
            sys.exit(1)
        if args.keyring:
            try:
                password = keyring.get_password(host, username)
            except Exception as e:
                print(f"Error: {str(e)}")
                sys.exit(1)
        elif password == None:
            print("Error: password must be supplied")
            sys.exit(1)

    # Get clipboard content
    clipboard_content, typename = get_clipboard_content()

    # Get filename
    if typename == 'img':
        filename = 'clipboard.png'
    else:
        filename = 'clipboard.txt'
    local_path = '/tmp/' + filename
    remote_path = remote + '/' + filename

    # Write to local file
    if typename == 'img':
        clipboard_content.savev(local_path, 'png', [], [])
    else:
        with open(local_path, 'w') as file:
            file.write(clipboard_content)

    # Upload file to FTP server
    upload_to_ftp(host, username, password, active, local_path, remote_path)

    # Remove temporary file
    os.unlink(local_path)

