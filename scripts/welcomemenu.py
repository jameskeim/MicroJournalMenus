#!/usr/bin/env python3
"""
MICRO JOURNAL 3000 Welcome Menu
Optimized for 40% keyboard and 12-line display
"""

import os
import sys
from consolemenu import ConsoleMenu
from consolemenu.items import CommandItem, FunctionItem, SubmenuItem
from consolemenu.format import MenuBorderStyleType

def create_writing_menu():
    """Create the writing tools submenu"""
    writing_menu = ConsoleMenu("\033[96m* Writing Tools *\033[0m", 
                              clear_screen=False)
    
    writing_menu.append_item(CommandItem("\033[93mM\033[0m - Markdown Document", 
                                       "~/.microjournal/scripts/newMarkDown.sh"))
    writing_menu.append_item(CommandItem("\033[93mW\033[0m - WordGrinder Document", 
                                       "~/.microjournal/scripts/newwrdgrndr.sh"))
    
    return writing_menu

def create_system_menu():
    """Create the system tools submenu"""
    system_menu = ConsoleMenu("\033[96m* System Tools *\033[0m", 
                             clear_screen=False)
    
    system_menu.append_item(CommandItem("\033[93mS\033[0m - File Share", 
                                      "~/.microjournal/scripts/share.sh"))
    system_menu.append_item(CommandItem("\033[93mC\033[0m - Pi Config", 
                                      "~/.microjournal/scripts/config.sh"))
    system_menu.append_item(CommandItem("\033[93mI\033[0m - System Info", "neofetch"))
    
    return system_menu

def create_fun_menu():
    """Create the fun tools submenu"""
    fun_menu = ConsoleMenu("\033[96m* Fun Tools *\033[0m", 
                          clear_screen=False)
    
    fun_menu.append_item(CommandItem("\033[93mT\033[0m - Digital Clock", 
                                   "tty-clock -c -t -B -S -C 3"))
    fun_menu.append_item(CommandItem("\033[93mX\033[0m - Matrix Effect", "cmatrix -c cyan"))
    
    return fun_menu

def main():
    # Try to use ASCII borders to remove box drawing
    try:
        from consolemenu.format import MenuFormatBuilder
        formatter = MenuFormatBuilder().set_border_style_type(MenuBorderStyleType.ASCII_BORDER)
    except:
        formatter = None
    
    # Create main menu with colors and formatting
    menu = ConsoleMenu("\033[96m*** MICRO JOURNAL 3000 ***\033[0m", 
                      subtitle="\033[93mPortable Writing Station\033[0m",
                      formatter=formatter,
                      clear_screen=True)
    
    # Create submenus
    writing_menu = create_writing_menu()
    system_menu = create_system_menu()
    fun_menu = create_fun_menu()
    
    # Add submenu items to main menu with colors
    menu.append_item(SubmenuItem("\033[92mW\033[0m - Writing Tools", writing_menu, menu))
    menu.append_item(SubmenuItem("\033[92mS\033[0m - System Tools", system_menu, menu))
    menu.append_item(SubmenuItem("\033[92mF\033[0m - Fun Tools", fun_menu, menu))
    
    # Add direct actions
    def start_shell():
        print("\033[93mStarting shell session...\033[0m")
        print("Type 'exit' to return to menu")
        os.system('/bin/bash')
    
    menu.append_item(FunctionItem("\033[92mE\033[0m - Shell Session", start_shell))
    menu.append_item(CommandItem("\033[91mQ\033[0m - Shutdown", "~/.microjournal/scripts/shutdown.sh"))
    
    # Show the menu
    menu.show()

if __name__ == "__main__":
    main()
