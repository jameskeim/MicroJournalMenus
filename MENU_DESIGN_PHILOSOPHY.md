# Menu System Design Philosophy
## Honoring Hardware Craftsmanship Through Software Design

### The Micro Journal Legacy

The Micro Journal writer deck, created by Un Kyu Lee and sold on Tindie, represents a masterful attention to hardware design. From the carefully selected ortholinear keyboard layouts to the thoughtful integration of e-ink displays and leather carrying straps, every aspect of Un Kyu Lee's hardware design reflects a deep commitment to the craft of distraction-free writing.

This menu system was developed to honor that same level of design attention in software.

### Design Principles

#### **Visual Excellence Meets Functional Simplicity**
Just as Un Kyu Lee's hardware balances aesthetic beauty with writing functionality, this menu system uses the `gum` library to create visually appealing, professionally styled interfaces that feel worthy of the hardware they run on. The colored column layout, rounded borders, and thoughtful typography create a menu system that matches the quality of the physical device.

#### **Configurable by Writers, Not Just Programmers**
The Micro Journal community consists of writers, journalists, and creative professionals—people who are "more familiar with a thesaurus than a tuple." The configuration system uses simple, descriptive variable names:

```bash
COLUMN1_NAME="WRITING"
COL1_ITEMS=(
  "M:Markdown:./scripts/newMarkDown.sh"
  "W:Wordgrinder:./scripts/newwrdgrndr.sh"
)
```

This approach ensures that users can customize their writing environment without needing programming expertise, maintaining the same accessibility philosophy that makes the Micro Journal hardware approachable to all writers.

#### **Respecting Hardware Constraints**
The Raspberry Pi Zero 2W's 512MB RAM constraint demands careful resource management. Unlike Python-based menu systems that keep a 25-30MB interpreter resident in memory, this bash-based approach uses only 2-3MB while running. This design philosophy ensures maximum memory availability for actual writing applications—NeoVim, WordGrinder, and other creative tools.

#### **Optimized for Limited Screen Real Estate**
The Micro Journal's compact display (typically 98 characters × 12 lines) requires every pixel to serve a purpose. The column-based layout maximizes information density while maintaining visual clarity. The intelligent caching system ensures that complex menu rendering doesn't impact the immediacy that writers expect from their tools.

### Technical Philosophy

#### **Smart Caching for Responsive Performance**
The menu generation is cached after the first render, recognizing that writers rarely change their workflow configurations. This architectural decision prioritizes the user experience—menus appear instantly after the initial setup, preserving the "power on and write" philosophy that makes the Micro Journal hardware so compelling.

#### **Separation of Concerns**
The clear division between user-configurable elements and system logic ensures that the menu can grow with users' needs without requiring deep technical knowledge. Writers can modify their workflow while the underlying system maintains its efficiency and reliability.

### Conclusion

This menu system exists to bridge the gap between Un Kyu Lee's exceptional hardware craftsmanship and the software experience that writers deserve. By prioritizing visual design, user accessibility, and resource efficiency, it creates a software environment worthy of the thoughtful hardware it runs on.

In a world of bloated applications and complex interfaces, both the Micro Journal hardware and this menu system represent a return to purposeful design—every element serves the fundamental goal of distraction-free writing.

*The best tools disappear into the background, allowing creativity to flourish. This menu system aspires to be such a tool.*