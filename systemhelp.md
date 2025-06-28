# MICRO JOURNAL 2000 System Help

*Complete User Guide and Reference Documentation*

---

## Table of Contents {#table-of-contents}

### [System Overview](#system-overview)
- [Philosophy & Design](#philosophy-design)
- [Hardware Requirements](#hardware-requirements)
- [Display Optimization](#display-optimization)

### [Main Menu System](#main-menu-system)
- [Menu Layout](#menu-layout)
- [Navigation Basics](#navigation-basics)
- [Column Organization](#column-organization)

### [DRAFT Column](#draft-column)
- [M - Markdown Editor](#markdown-editor)
- [V - NeoVim](#neovim)
- [J - Journal System](#journal-system)
- [N - Notes System](#notes-system)
- [O - Outliner](#outliner)

### [PROCESS Column](#process-column)
- [G - Set Goals](#set-goals)
- [C - Word Count](#word-count)
- [E - Explore Notes](#explore-notes)
- [D - Dashboard](#dashboard)

### [SHARE Column](#share-column)
- [S - Share Files](#share-files)
- [F - File Manager](#file-manager)
- [B - Backup](#backup)

### [PAUSE Column](#pause-column)
- [P - Writing Prompts](#writing-prompts)
- [I - Inspirations](#inspirations)
- [K - Keyboarding Practice](#keyboarding-practice)
- [X - Matrix Screensaver](#matrix-screensaver)

### [CONTROL Column](#control-column)
- [Z - Z Shell](#z-shell)
- [A - About System](#about-system)
- [W - WiFi Management](#wifi-management)
- [H - Help](#help)
- [Q - Quit Options](#quit-options)

### [Hidden Options](#hidden-options)
- [0 - Exit Menu](#exit-menu)
- [1 - Reload Menu](#reload-menu)
- [2 - Pi Configuration](#pi-configuration)

### [Advanced Topics](#advanced-topics)
- [File Organization](#file-organization)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Performance Tips](#performance-tips)

---

## System Overview {#system-overview}

### Philosophy & Design {#philosophy-design}

The MICRO JOURNAL 2000 embodies a philosophy of **distraction-free writing** through purposeful design. Every element serves the fundamental goal of helping writers focus on their craft without technological interference.

**Core Principles:**
- **Immediate Access**: Power on and start writing within seconds
- **Visual Excellence**: Beautiful, professional interfaces using the `gum` library
- **Resource Efficiency**: Optimized for Raspberry Pi Zero 2W's 512MB RAM
- **Writer-Centric**: Designed by writers, for writers
- **Configurable Simplicity**: Powerful features with simple interfaces

### Hardware Requirements {#hardware-requirements}

**Minimum System:**
- Raspberry Pi Zero 2W (512MB RAM)
- MicroSD card (8GB minimum, 32GB recommended)
- Compatible keyboard (mechanical preferred)
- Display capable of 98×12 character output

**Optimal Setup:**
- Fast MicroSD card (Class 10 or better)
- Mechanical keyboard with good tactile feedback
- E-ink or LCD display optimized for text
- External battery for extended sessions

### Display Optimization {#display-optimization}

The system is optimized for **98 characters × 12 lines** displays, ensuring:
- Maximum information density
- Clean, readable layouts
- Efficient use of screen real estate
- Consistent visual hierarchy

---

## Main Menu System {#main-menu-system}

### Menu Layout {#menu-layout}

The main menu organizes all system functions into five logical columns:

```
MICRO JOURNAL 2000
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│  DRAFT  │ PROCESS │  SHARE  │  PAUSE  │ CONTROL │
├─────────┼─────────┼─────────┼─────────┼─────────┤
│M Markdown│G Goals  │S Share  │P Prompts│Z Shell  │
│V NeoVim │C Count  │F Files  │I Inspire│A About  │
│J Journal│E Explore│B Backup │K Keyboard│W WiFi   │
│N Notes  │D Dashbrd│         │X Matrix │H Help   │
│O Outline│         │         │         │Q Quit   │
└─────────┴─────────┴─────────┴─────────┴─────────┘
```

### Navigation Basics {#navigation-basics}

**Selection Methods:**
- Press any highlighted letter to select that option
- Keys are case-insensitive (M or m both work)
- Invalid selections show a brief error message

**Special Navigation:**
- `0` - Exit to shell (hidden option)
- `1` - Reload menu system (hidden option)  
- `2` - Access Pi configuration (hidden option)

### Column Organization {#column-organization}

Each column represents a different aspect of the writing workflow:

- **DRAFT**: Creating new content
- **PROCESS**: Analyzing and organizing existing content
- **SHARE**: Distributing and backing up work
- **PAUSE**: Taking breaks and finding inspiration
- **CONTROL**: System management and configuration

---

## DRAFT Column {#draft-column}

*Tools for creating new written content*

### M - Markdown Editor {#markdown-editor}

**Purpose**: Quick access to markdown file creation with automatic timestamping.

**What It Does:**
- Creates new markdown file with format: `YYYY.MM.DD-HHMM.md`
- Opens file in NeoVim for immediate editing
- Saves files to `~/Documents/` directory

**Usage Instructions:**
1. Press `M` from main menu
2. System generates timestamped filename automatically
3. NeoVim opens with blank document ready for writing
4. Write your content using standard markdown syntax
5. Save with `:w` and quit with `:q` in NeoVim

**File Naming Convention:**
- `2025.01.15-0930.md` - Morning writing session
- `2025.01.15-1430-story-ideas.md` - Afternoon session with description

**Script Location**: `~/.microjournal/scripts/newMarkDown.sh`

### V - NeoVim {#neovim}

**Purpose**: Direct access to the NeoVim text editor without file creation.

**What It Does:**
- Launches NeoVim text editor
- Allows opening existing files or creating new ones
- Full NeoVim functionality available

**Usage Instructions:**
1. Press `V` from main menu
2. NeoVim starts in normal mode
3. Use standard NeoVim commands:
   - `:e filename` - Open existing file
   - `:new` - Create new buffer
   - `:w filename` - Save with specific name

**NeoVim Quick Reference:**
- `i` - Insert mode
- `Esc` - Normal mode
- `:w` - Save file
- `:q` - Quit
- `:wq` - Save and quit

### J - Journal System {#journal-system}

**Purpose**: Dedicated personal journaling with automatic organization and beautiful reading.

**What It Does:**
- Maintains single journal file at `~/Documents/journal/myjournal.md`
- Automatically adds date/time headers
- Supports multiple entries per day
- Provides beautiful reading mode with `glow`

**Usage Instructions:**

#### Creating New Entry:
1. Press `J` from main menu
2. System adds new header: `## Monday, January 15, 2025`
3. Adds time entry: `### 14:30`
4. Opens editor positioned for immediate writing

#### Journal Menu Options:
- **N) New Entry** - Add timestamped entry (default)
- **R) Read (Glow)** - Beautiful formatted reading
- **T) Recent Entries** - Show last few entries
- **S) Search** - Find content in journal
- **O) Open Editor** - Edit without new entry
- **C) Check Structure** - Validate journal format

#### Journal Structure:
```markdown
# My Personal Journal

## Monday, January 15, 2025

### 09:30
Morning thoughts and reflections...

### 15:45
Afternoon insights...

---

## Sunday, January 14, 2025

### 20:15
Evening reflections...
```

**Reading Mode Features:**
- Formatted display with proper typography
- Hierarchical header styling
- Pagination for long journals
- Search functionality within reader

**Script Location**: `~/.microjournal/scripts/journal.sh`

### N - Notes System {#notes-system}

**Purpose**: Powerful knowledge management with wiki-style linking and templates.

**What It Does:**
- Creates interconnected notes with [[wiki links]]
- Supports templates for structured content
- Provides fast search and discovery
- Terminal Velocity-style instant access

**Usage Instructions:**

#### Creating Notes:
1. Press `N` from main menu
2. If `fzf` available: Instant search/create interface
3. If not available: Simple menu-driven creation
4. Type note name or search existing notes
5. New notes auto-created with proper headers

#### Note Features:
- **Wiki Links**: `[[Note Name]]` creates automatic connections
- **Templates**: Character, plot, scene, worldbuilding templates
- **Hashtags**: `#writing #ideas` for categorization
- **Search**: Full-text search across all notes

#### Advanced Commands:
```bash
notes.sh grep "search term"     # Search content
notes.sh tags                   # List all hashtags
notes.sh links "note name"      # Show connections
notes.sh mv "old" "new"         # Rename notes
```

**Storage**: `~/Documents/notes/`
**Templates**: `~/.microjournal/templates/`
**Script Location**: `~/.microjournal/scripts/notes.sh`

### O - Outliner {#outliner}

**Purpose**: Hierarchical note organization using HNB (Hierarchical Notebook).

**What It Does:**
- Creates structured, tree-based documents
- Supports collapsible sections
- Ideal for project planning and organization
- Exports to various formats

**Usage Instructions:**
1. Press `O` from main menu
2. HNB outliner launches
3. Use arrow keys to navigate
4. `Tab` to indent, `Shift+Tab` to outdent
5. `Enter` to create new items

**HNB Quick Commands:**
- `F2` - Save
- `F3` - Load file
- `F10` - Exit
- `Insert` - Add new node
- `Delete` - Remove node

**Note**: Requires HNB to be installed (`sudo apt install hnb`)

---

## PROCESS Column {#process-column}

*Tools for analyzing and organizing your writing*

### G - Set Goals {#set-goals}

**Purpose**: Writing goal management and progress tracking.

**What It Does:**
- Set daily and weekly word count targets
- Track writing streaks and consistency
- Provide motivational feedback and encouragement
- Integrate with word count analytics

**Usage Instructions:**
1. Press `G` from main menu
2. Set daily word count goal (e.g., 500 words)
3. Set weekly targets for sustained progress
4. System tracks progress automatically
5. View encouragement and streak information

**Goal Types:**
- **Daily Goals**: Target words per day
- **Weekly Goals**: Sustained writing targets
- **Streak Goals**: Consecutive writing days
- **Project Goals**: Longer-term objectives

**Progress Display:**
```
Daily Goal: ████████░░ 80% (400/500 words)
Weekly: 2,847/3,500 words
Streak: 🔥 Day 7 of consistent writing
```

**Script Integration**: Works with `wordcount.sh` and stores config in `~/.microjournal/config`

### C - Word Count {#word-count}

**Purpose**: Comprehensive writing analytics and progress tracking.

**What It Does:**
- Analyzes individual files with detailed metrics
- Tracks daily writing progress with session breakdown
- Shows recent writing activity and trends
- Provides readability analysis and writing insights

**Usage Instructions:**

#### Main Menu Options:
- **T) Today's Writing** - Current day's progress
- **R) Recent Files** - Last 5 files with analytics
- **F) Specific File** - Detailed analysis of chosen file
- **A) All Files** - Complete corpus overview

#### Today's Writing Display:
```
Today (2025.01.15):
DATE       TIME   WC   TITLE
2025.01.15 09:30  0247 morning-writing
2025.01.15 16:45  0156 evening-notes

Total: 2 files, 403 words
```

#### File Analysis Features:
- Word, character, line, paragraph counts
- Reading time estimation
- Flesch readability score
- Vocabulary diversity analysis
- Most common words (excluding stop words)

#### Recent Files Tracking:
- Chronological display of last 5 modified files
- Quick overview of writing patterns
- Session analysis and productivity trends

**Script Location**: `~/.microjournal/scripts/wordcount.sh`

### E - Explore Notes {#explore-notes}

**Purpose**: Advanced note discovery and knowledge management.

**What It Does:**
- Browse notes by tags and categories
- Explore wiki-link connections between notes
- Search across note content with context
- Find orphaned notes without connections
- Generate note statistics and insights

**Usage Instructions:**

#### Exploration Menu:
- **T) Browse Tags** - Interactive tag selection with `fzf`
- **L) Link Explorer** - Discover note connections
- **S) Search Content** - Full-text search with context
- **O) Orphan Notes** - Find unconnected notes
- **N) Note Statistics** - Corpus analytics

#### Tag Browsing:
1. Press `T` to browse tags
2. `fzf` interface shows all hashtags
3. Select tag to see related notes
4. Preview shows note connections

#### Link Explorer:
1. Press `L` for link exploration
2. Select note file with `fzf`
3. View all outgoing [[wiki links]]
4. See incoming backlinks from other notes

#### Search Features:
- Context-aware search results
- Multiple file result selection
- Preview of matching content
- Highlighting of search terms

**Script Location**: `~/.microjournal/scripts/notes-explorer.sh`

### D - Dashboard {#dashboard}

**Purpose**: Centralized overview of writing activity and system status.

**Current Status**: Placeholder for future development.

**Planned Features:**
- Unified view of goals, progress, and recent activity
- Writing streak status and motivation
- System health and performance metrics
- Quick access to most-used functions

**Implementation Note**: This option currently needs definition. Consider what dashboard features would be most valuable for your writing workflow.

---

## SHARE Column {#share-column}

*Tools for distributing and backing up your work*

### S - Share Files {#share-files}

**Purpose**: Easy file sharing and transfer via web interface.

**What It Does:**
- Starts NetworkManager service for connectivity
- Launches web-based file browser on port 8080
- Provides browser access to `~/Documents` folder
- Allows file download, upload, and management

**Usage Instructions:**
1. Press `S` from main menu
2. System starts network services
3. Web interface launches at `http://[IP_ADDRESS]:8080`
4. Access displayed IP address from another device
5. Browse and download files through web interface
6. Press `Ctrl+C` to stop sharing and disable network

**Security Notes:**
- Network access is temporary (only while sharing)
- No authentication required (use on trusted networks)
- Automatically disables networking when finished

**Web Interface Features:**
- File browsing and navigation
- Download individual files or folders
- Upload files from other devices
- Basic file management operations

**Script Location**: `~/.microjournal/scripts/share.sh`

### F - File Manager {#file-manager}

**Purpose**: Terminal-based file management and organization.

**What It Does:**
- Launches configured file manager (default: Yazi)
- Browse and organize documents
- Move, copy, delete, and rename files
- Preview file contents

**Usage Instructions:**
1. Press `F` from main menu
2. File manager opens in `~/Documents` directory
3. Use arrow keys to navigate
4. `Enter` to open files/folders
5. `q` to quit file manager

**Default File Manager (Yazi):**
- Modern terminal file manager
- Vi-style key bindings
- File preview and syntax highlighting
- Bulk operations support

**Fallback**: If Yazi not installed, falls back to `ls -la` directory listing.

### B - Backup {#backup}

**Purpose**: Data backup and archive management.

**Current Status**: Placeholder for future implementation.

**Planned Features:**
- Automated document backup to external storage
- Version control integration
- Cloud backup configuration
- Archive management for old documents

---

## PAUSE Column {#pause-column}

*Tools for inspiration and mental breaks*

### P - Writing Prompts {#writing-prompts}

**Purpose**: Creative writing inspiration and idea generation.

**What It Does:**
- Displays random writing prompts from built-in library
- Allows adding custom prompts
- Browse all available prompts
- Statistics on prompt usage

**Usage Instructions:**

#### Main Menu:
- **R) Random Prompt** - Show inspiring writing prompt
- **A) Add Prompt** - Contribute custom prompts
- **B) Browse All** - Paginated view of all prompts
- **S) Statistics** - Usage stats and system info

#### Using Random Prompts:
1. Press `P` from main menu, then `R`
2. System displays creative writing prompt
3. Use prompt for immediate writing or later inspiration
4. Press any key for another prompt or `Q` to return

#### Adding Custom Prompts:
1. Select `A) Add Prompt`
2. Enter your writing prompt idea
3. Prompt saved to personal collection
4. Available in future random selections

#### Built-in Prompt Examples:
- "Write about a color that doesn't exist yet."
- "Describe your morning routine from your coffee mug's perspective."
- "A character finds a door in their house that wasn't there yesterday."

**Storage**: Custom prompts in `~/.microjournal/prompts/custom.txt`
**Script Location**: `~/.microjournal/scripts/prompts.sh`

### I - Inspirations {#inspirations}

**Purpose**: Literary quotations and inspirational text display.

**What It Does:**
- Shows random inspirational quotes from literature and art
- Centered, beautiful display using `gum` styling
- Continuous browsing for extended inspiration sessions

**Usage Instructions:**
1. Press `I` from main menu
2. Random quotation appears centered on screen
3. Press any key for another quote
4. Press `Q` to return to main menu

**Quote Sources:**
- Fortune database (art and literature collections)
- Under 400 characters for display optimization
- Curated for writing inspiration and motivation

**Display Features:**
- Centered text for optimal reading
- Soft color highlighting
- Clean, distraction-free presentation

**Requirements**: Requires `fortune` command (`sudo apt install fortune-mod`)
**Script Location**: `~/.microjournal/scripts/inspirations.sh`

### K - Keyboarding Practice {#keyboarding-practice}

**Purpose**: Typing practice and keyboard skill development.

**What It Does:**
- Launches typing tutor for skill improvement
- Practice typing accuracy and speed
- Maintain muscle memory for mechanical keyboards

**Usage Instructions:**
1. Press `K` from main menu
2. Typing tutor launches (default: `tt`)
3. Follow on-screen instructions for exercises
4. Exit tutor to return to main menu

**Default Tutor**: TT (Terminal Typing)
**Fallback**: Message if typing tutor not installed
**Installation**: `sudo apt install tt` or similar typing software

### X - Matrix Screensaver {#matrix-screensaver}

**Purpose**: Visual break with Matrix-style animation.

**What It Does:**
- Displays Matrix-style falling character animation
- Cyan color scheme for retro aesthetic
- Continuous animation until keypress

**Usage Instructions:**
1. Press `X` from main menu
2. Matrix animation begins
3. Press any key to return to menu

**Visual Features:**
- Cyan character rain animation
- Full-screen coverage
- Smooth scrolling effects

**Requirements**: Requires `cmatrix` command (`sudo apt install cmatrix`)

---

## CONTROL Column {#control-column}

*System management and configuration tools*

### Z - Z Shell {#z-shell}

**Purpose**: Direct access to command line interface.

**What It Does:**
- Launches configured shell (default: Zsh)
- Provides full system access for advanced users
- Maintains virtual environment if active

**Usage Instructions:**
1. Press `Z` from main menu
2. Shell prompt appears
3. Execute any system commands
4. Type `exit` to return to menu

**Shell Features:**
- Full Zsh functionality with configuration
- Access to all system tools
- Virtual environment preserved
- History and aliases available

**Fallback**: Falls back to Bash if Zsh not available

### A - About System {#about-system}

**Purpose**: System information and hardware details.

**What It Does:**
- Displays comprehensive system information using Neofetch
- Shows hardware specifications
- Operating system details
- Resource usage and performance metrics

**Usage Instructions:**
1. Press `A` from main menu
2. Neofetch displays system information
3. Press any key to return to menu

**Information Displayed:**
- Operating system and kernel version
- Hardware model and specifications
- Memory and storage usage
- Uptime and performance metrics
- ASCII art logo

**Requirements**: Requires `neofetch` (`sudo apt install neofetch`)

### W - WiFi Management {#wifi-management}

**Purpose**: Network connectivity management with security awareness.

**What It Does:**
- Enable/disable WiFi and SSH services
- Check network connectivity status
- Security warnings for SSH users
- Service status monitoring

**Usage Instructions:**

#### Network Menu Options:
- **Enable Networking** - Start WiFi and SSH services
- **Disable Networking** - Stop all network services  
- **Check Status** - View service status and connectivity
- **Exit** - Return to main menu

#### Enabling Network:
1. Press `W` from main menu
2. Select "Enable Networking"
3. NetworkManager and SSH services start
4. System shows success/failure status

#### Disabling Network:
1. Select "Disable Networking"
2. **Warning displayed for SSH users**
3. Confirm action to proceed
4. Services stop, network disconnected

#### Status Display:
```
Current Status: Online ✓
NetworkManager: Active ✓
SSH Service: Active ✓
Internet connectivity: Available ✓
```

**Security Features:**
- SSH disconnect warning for remote users
- Confirmation required for network disable
- Clear status indicators
- Service dependency handling

**Script Location**: `~/.microjournal/scripts/network.sh`

### H - Help {#help}

**Purpose**: Access system documentation and README.

**What It Does:**
- Displays main system README file
- Provides usage instructions and tips
- Documents key features and configuration

**Usage Instructions:**
1. Press `H` from main menu
2. README content displays in pager
3. Use arrow keys or page up/down to navigate
4. Press `q` to exit help

**Help Content Includes:**
- Basic system overview
- Key feature explanations
- Configuration instructions
- Troubleshooting tips

**Source**: Displays `~/.microjournal/README.md`

### Q - Quit Options {#quit-options}

**Purpose**: Safe system shutdown and restart options.

**What It Does:**
- Provides safe shutdown and reboot options
- Includes confirmation prompts for safety
- Syncs filesystem before power operations

**Usage Instructions:**

#### Quit Menu Options:
- **S) Shutdown System** - Complete power off
- **R) Reboot System** - Restart system
- **[Invalid Choice]** - Return to main menu

#### Shutdown Process:
1. Press `Q` from main menu, then `S`
2. Warning about system shutdown displayed
3. Confirmation prompt: "Are you sure?"
4. If confirmed: filesystem sync, then shutdown
5. If cancelled: return to main menu

#### Reboot Process:
1. Press `Q` from main menu, then `R`
2. Warning about system restart displayed
3. Confirmation prompt required
4. If confirmed: filesystem sync, then reboot

**Safety Features:**
- Confirmation required for all power operations
- Filesystem sync before shutdown/reboot
- Clear warnings about operation consequences
- Cancellation option at confirmation stage

**Script Location**: `~/.microjournal/scripts/quit.sh`

---

## Hidden Options {#hidden-options}

*Special functions not displayed in main menu*

### 0 - Exit Menu {#exit-menu}

**Purpose**: Quick exit to shell without shutdown.

**What It Does:**
- Immediately exits menu system
- Returns to shell prompt
- Preserves all running services

**Usage**: Press `0` from main menu (not displayed)

### 1 - Reload Menu {#reload-menu}

**Purpose**: Refresh menu system and reload configuration.

**What It Does:**
- Clears menu cache
- Reloads menu script with latest changes
- Useful for development and troubleshooting

**Usage**: Press `1` from main menu (not displayed)

### 2 - Pi Configuration {#pi-configuration}

**Purpose**: Access Raspberry Pi system configuration.

**What It Does:**
- Temporarily starts NetworkManager
- Launches `raspi-config` system tool
- Stops NetworkManager after configuration

**Usage**: Press `2` from main menu (not displayed)

**Configuration Options Available:**
- Display settings
- Interface options (SSH, SPI, I2C, etc.)
- Performance settings
- Localization options
- User password changes

**Script Location**: `~/.microjournal/scripts/config.sh`

---

## Advanced Topics {#advanced-topics}

### File Organization {#file-organization}

#### Directory Structure:
```
~/
├── Documents/
│   ├── *.md                    # Timestamped writing files
│   ├── journal/
│   │   └── myjournal.md       # Personal journal
│   └── notes/
│       ├── *.md               # Wiki-linked notes
│       └── [note files]
├── .microjournal/
│   ├── scripts/               # System scripts
│   ├── templates/             # Note templates
│   ├── prompts/               # Writing prompts
│   ├── config                 # System configuration
│   └── menu_cache            # Menu display cache
```

#### File Naming Conventions:

**Writing Files**: `YYYY.MM.DD-HHMM[-description].md`
- `2025.01.15-0930.md` - Morning session
- `2025.01.15-1430-story-ideas.md` - Afternoon with description

**Notes**: `topic-name.md` or `topic_name_TYPE.md`
- `character-notes.md` - General character notes
- `protagonist_CHARACTER.md` - Template-based character
- `world-building_WORLDBUILDING.md` - Template-based world

### Customization {#customization}

#### Menu Configuration:
Edit `~/.microjournal/scripts/menu` to customize:

```bash
# Column names
COLUMN1_NAME="DRAFT"
COLUMN2_NAME="PROCESS"

# Menu items (format: "KEY:Display Name:Command")
COL1_ITEMS=(
  "M:Markdown:$MCRJRNL/scripts/newMarkDown.sh"
  "V:NeoVim:$EDITOR"
)
```

#### Environment Variables:
```bash
EDITOR="nvim"              # Default text editor
FILE_MANAGER="yazi"        # File manager command
SHELL_CMD="/bin/zsh"       # Shell for Z option
```

#### Adding Custom Scripts:
1. Create script in `~/.microjournal/scripts/`
2. Make executable: `chmod +x script-name.sh`
3. Add to menu configuration
4. Reload menu with `1` key

### Troubleshooting {#troubleshooting}

#### Common Issues:

**Menu Won't Load:**
- Check `gum` installation: `sudo apt install gum`
- Verify script permissions: `chmod +x ~/.microjournal/scripts/menu`
- Reload menu cache with `1` key

**Scripts Fail to Execute:**
- Verify file permissions: `chmod +x ~/.microjournal/scripts/*.sh`
- Check command dependencies (fzf, glow, neofetch, etc.)
- Review error messages in terminal

**Network Issues:**
- Ensure WiFi module is functioning
- Check NetworkManager service status
- Verify 2.4GHz network availability (5GHz not supported)

**Performance Issues:**
- Clear menu cache: `rm ~/.microjournal/menu_cache`
- Check available memory: `free -h`
- Restart system if necessary

#### Log Locations:
- System logs: `/var/log/syslog`
- Service logs: `journalctl -u service-name`
- Script errors: Check terminal output

### Performance Tips {#performance-tips}

#### Memory Optimization:
- Menu system uses cached rendering for speed
- Scripts are bash-based to minimize memory usage
- Text editors are lightweight (NeoVim, WordGrinder)

#### Storage Management:
- Regular cleanup of temporary files
- Archive old writing files periodically
- Monitor SD card health and performance

#### Network Efficiency:
- Disable networking when not needed
- Use local file operations when possible
- Minimize background network services

#### Writing Optimization:
- Use markdown for fast rendering
- Keep individual files under 10,000 words
- Organize notes with clear naming conventions

---

## Quick Reference {#quick-reference}

### Essential Key Bindings:
- `M` - New markdown file
- `J` - Journal entry
- `N` - Notes system
- `C` - Word count
- `S` - Share files
- `Q` - Shutdown options
- `0` - Exit to shell
- `1` - Reload menu

### File Locations:
- Writing files: `~/Documents/`
- Journal: `~/Documents/journal/myjournal.md`
- Notes: `~/Documents/notes/`
- System: `~/.microjournal/`

### Emergency Commands:
- `Ctrl+C` - Cancel current operation
- `0` then `exit` - Return to menu from shell
- `sudo reboot` - Force restart if system hangs

---

*This documentation covers MICRO JOURNAL 2000 system version as of January 2025. For updates and additional information, visit the project repository or use the `H` help option from the main menu.*
