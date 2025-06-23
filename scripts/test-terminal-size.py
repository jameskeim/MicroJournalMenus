#!/usr/bin/env python3
"""
Test terminal size detection in fbterm
"""

import os
import sys
import subprocess

def test_terminal_size():
    print("=== Terminal Size Detection Test ===")
    print(f"TERM environment variable: {os.environ.get('TERM', 'not set')}")
    print()
    
    # Test 1: os.get_terminal_size()
    print("1. Testing os.get_terminal_size():")
    try:
        size = os.get_terminal_size()
        print(f"   ✓ Success: {size.columns} columns × {size.lines} lines")
        width_from_os = size.columns
    except Exception as e:
        print(f"   ✗ Failed: {e}")
        width_from_os = None
    
    print()
    
    # Test 2: stty size
    print("2. Testing 'stty size' command:")
    try:
        result = subprocess.run(['stty', 'size'], 
                              capture_output=True, 
                              text=True, 
                              timeout=2)
        if result.returncode == 0:
            output = result.stdout.strip()
            lines, cols = output.split()
            print(f"   ✓ Success: {cols} columns × {lines} lines")
            width_from_stty = int(cols)
        else:
            print(f"   ✗ Failed: stty returned code {result.returncode}")
            print(f"   stderr: {result.stderr}")
            width_from_stty = None
    except Exception as e:
        print(f"   ✗ Failed: {e}")
        width_from_stty = None
    
    print()
    
    # Test 3: Environment variables
    print("3. Testing environment variables:")
    cols_env = os.environ.get('COLUMNS')
    lines_env = os.environ.get('LINES')
    print(f"   COLUMNS = {cols_env}")
    print(f"   LINES = {lines_env}")
    
    print()
    
    # Test 4: Manual ioctl (low-level)
    print("4. Testing manual ioctl TIOCGWINSZ:")
    try:
        import fcntl
        import termios
        import struct
        
        # Try stdout first
        h, w, _, _ = struct.unpack('HHHH', 
                                   fcntl.ioctl(sys.stdout.fileno(), 
                                              termios.TIOCGWINSZ,
                                              struct.pack('HHHH', 0, 0, 0, 0)))
        print(f"   ✓ Success (stdout): {w} columns × {h} lines")
        width_from_ioctl = w
    except Exception as e:
        print(f"   ✗ Failed: {e}")
        width_from_ioctl = None
    
    print()
    
    # Summary
    print("=== Summary ===")
    methods = {
        'os.get_terminal_size()': width_from_os,
        'stty size': width_from_stty,
        'manual ioctl': width_from_ioctl,
        'COLUMNS env var': int(cols_env) if cols_env and cols_env.isdigit() else None
    }
    
    working_methods = [(name, width) for name, width in methods.items() if width is not None]
    
    if working_methods:
        print("Working methods:")
        for name, width in working_methods:
            print(f"   {name}: {width} columns")
        
        # Check if they all agree
        widths = [width for _, width in working_methods]
        if len(set(widths)) == 1:
            print(f"\n✓ All methods agree: terminal is {widths[0]} columns wide")
        else:
            print(f"\n⚠ Methods disagree: {dict(working_methods)}")
    else:
        print("✗ No methods worked - falling back to 80 columns")
    
    print()
    print("Try resizing your terminal window and run this script again")
    print("to test if terminal size changes are detected properly.")

if __name__ == "__main__":
    test_terminal_size()
