A World of Warcraft interface addon that shows the last used abilities of party and arena members.

[Video preview](https://www.youtube.com/watch?v=CtwDSMJs4Dc)

## Features
1. Move, resize and change the direction of the ability icons
2. Masque icon customization
3. Add abilities to the ignore list
4. Copy settings from one character to another
5. Player cast timing below each icon: GCD gap or time between casts

## Player cast timing
Open `/tgcd` and choose **Player cast timing**:
- **GCD gap (seconds)** (default): idle time after both the previous GCD and the previous cast/channel have ended, rounded to one decimal place. An instant spell with a 1.2-second GCD followed by a cast at 1.5 seconds shows `0.3` below the next icon. A 2-second cast with a 1.3-second GCD followed immediately by the next cast shows `0.0`; waiting another 0.3 seconds shows `0.3`. Consecutive queued casts show `0.0`.
- **Time between casts**: elapsed seconds between player cast starts (including off-GCD actions), without subtracting the GCD.
- **Off**: hide the numbers.

**Number font** lists the fonts registered by installed addons with LibSharedMedia, along with **Game default**. The list refreshes when opened, including fonts registered after TrufiGCD loads. **Font size** sets the number size independently of the icons; **Auto** keeps the original sizing based on icon size. A preview and the existing icons update immediately. These choices are saved per profile. If a selected font is unavailable, the game font is used until it becomes available.

In **Time between casts** mode, leaving combat resets the reference. Thirty seconds without a new cast while out of combat also resets it. The next cast shows `0.0`, then counting resumes from that cast. Switching into this mode also starts a fresh reference. Existing icons retain their original numbers, and GCD-gap mode keeps its existing calculation.

Timing uses the player's actual global cooldown (spell `61304`), including haste effects such as Bloodlust. The fixed scrolling speed, icon count, filters, cancel marks, and other units' icons keep their existing behavior. Blocklisted casts still advance the timing reference. Supplementary successes without a cast GUID do not count as new actions. Cast-time spells are measured at their start, rather than counting their completion twice; channels and empowered casts also use their start.

The first cast after loading or resetting the queue has no previous reference, so its number is blank. Off-GCD abilities have no GCD-gap label and do not reset the GCD reference. Cast completion, cancellation, channel stop, and empowered-cast stop events determine when the player is no longer occupied; cast pushback is accounted for by observing the actual end rather than assuming the original duration. If the client returns restricted/secret cooldown timestamps, GCD gaps remain blank; elapsed mode still uses event timestamps. The gap measures idle time between casts, without diagnosing other reasons a spell might be unavailable (such as movement, crowd control, resources, or range).

## Slash Commands
- `/tgcd`
- `/trufigcd`

## Mirrors
- [CurseForge](https://www.curseforge.com/wow/addons/trufigcd)
- [Wago.io](https://addons.wago.io/addons/trufigcd)
- [WoW Interface](https://www.wowinterface.com/downloads/info21820.html)
