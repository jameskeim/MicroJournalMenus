#!/usr/bin/env python3
"""
MICRO JOURNAL 3000 - Simple Menu System
Clean version with no submenu complexity
"""

import os
import sys
import subprocess
import re
import termios
import tty

def clear_screen():
    os.system('clear')

def get_single_keypress():
    """Get a single keypress without requiring Enter"""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(sys.stdin.fileno())
        ch = sys.stdin.read(1)
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
    return ch

def center_text(text, width=80):
    """Center text within given width, ignoring ANSI color codes"""
    # Remove ANSI color codes to get actual visible length
    visible_text = re.sub(r'\033\[[0-9;]*m', '', text)
    visible_length = len(visible_text)
    
    if visible_length >= width:
        return text
    
    padding = (width - visible_length) // 2
    return ' ' * padding + text

def get_terminal_width():
    """Get terminal width with error handling"""
    try:
        size = os.get_terminal_size()
        return size.columns
    except (OSError, AttributeError):
        try:
            result = subprocess.run(['stty', 'size'], 
                                  capture_output=True, 
                                  text=True, 
                                  timeout=2)
            if result.returncode == 0:
                lines, cols = result.stdout.strip().split()
                return int(cols)
        except (subprocess.SubprocessError, ValueError, FileNotFoundError):
            pass
        
        try:
            return int(os.environ.get('COLUMNS', 80))
        except (ValueError, TypeError):
            pass
    
    return 80

def run_command(command):
    """Execute a shell command"""
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError as e:
        print(f"\033[91mError: {e}\033[0m")
        input("Press Enter to continue...")

def show_main_menu():
    """Display the main menu"""
    clear_screen()
    width = get_terminal_width()
    
    print()
    print(center_text("\033[91m▐▀▀▀▀▀▀\033[96m MICRO JOURNAL 3000 \033[91m▀▀▀▀▀▀▌\033[0m", width))
    print(center_text("\033[91m▐▄▄▄\033[0m \033[93mPortable Writing Station\033[0m \033[91m▄▄▄▌\033[0m", width))
    print()
    # Column alignment system: Each column width = longest text in that column + 1 space
    # Column 1: 16 chars ("W - Wordgrinder" = 15 + 1 space)
    # Column 2: 17 chars ("F - File Manager" = 16 + 1 space) 
    # Column 3: 15 chars ("U - Network Up" = 14 + 1 space)
    # Column 4: 15 chars ("L - Menu Reload" = 15, no extra space since it's last column)
    print(center_text("\033[92mM\033[0m - Markdown     \033[92mF\033[0m - File Manager  \033[92mU\033[0m - Network ⬆   \033[92mZ\033[0m - Z Shell    ", width))
    print(center_text("\033[92mW\033[0m - Wordgrinder  \033[92mS\033[0m - Share Files   \033[92mD\033[0m - Network ⬇   \033[92mL\033[0m - Menu Reload", width))
    print(center_text("\033[92mN\033[0m - Neovim       \033[92mI\033[0m - System Info   \033[92mT\033[0m - Time Clock  \033[91mQ\033[0m - Shutdown  ", width))
    print(center_text("\033[92mC\033[0m - Word Count   \033[92mP\033[0m - Pi Config     \033[92mX\033[0m - Matrix      \033[91mR\033[0m - Reboot    ", width))
    print()
    print(center_text("\033[96mMake a selection: \033[0m", width), end="", flush=True)

def handle_choice(choice):
    """Handle user menu choice"""
    choice = choice.lower()
    
    # Command mappings
    commands = {
        'm': '~/.microjournal/scripts/newMarkDown.sh',
        'w': '~/.microjournal/scripts/newwrdgrndr.sh', 
        'n': 'nvim',
        'c': '~/.microjournal/scripts/wordcount.sh',
        'f': 'yazi',
        's': '~/.microjournal/scripts/share.sh',
        'i': '~/.microjournal/scripts/sysinfo.sh',
        'p': '~/.microjournal/scripts/config.sh',
        'u': '~/.microjournal/scripts/network-enable.sh',
        'd': '~/.microjournal/scripts/network-disable.sh',
        't': 'tty-clock -c -t -B -S -C 3',
        'x': 'neo -c cyan',
        'q': '~/.microjournal/scripts/shutdown.sh',
        'r': '~/.microjournal/scripts/reboot.sh'
    }
    
    if choice == 'z':
        # Shell session
        clear_screen()
        width = get_terminal_width()
        print()
        print(center_text("\033[93mStarting shell...\033[0m", width))
        print(center_text("Type 'exit' to return to menu", width))
        print()
        os.system('/bin/zsh')
    elif choice == 'l':
        # Restart menu
        clear_screen()
        width = get_terminal_width()
        print()
        print(center_text("\033[93mRestarting menu...\033[0m", width))
        os.execv(sys.executable, [sys.executable] + sys.argv)
    elif choice in commands:
        # Run command
        run_command(commands[choice])
    else:
        # Invalid choice
        print(f"\n\033[91mInvalid choice: {choice}\033[0m")
        input("Press Enter...")

def main():
    """Main program loop"""
    while True:
        show_main_menu()
        try:
            choice = get_single_keypress()
            if choice == '\x03':  # Ctrl+C
                raise KeyboardInterrupt
            if choice == '\x04':  # Ctrl+D
                raise EOFError
            if choice.strip():
                handle_choice(choice)
        except (KeyboardInterrupt, EOFError):
            clear_screen()
            print("\n\033[93mGoodbye!\033[0m")
            break

if __name__ == "__main__":
    main()
