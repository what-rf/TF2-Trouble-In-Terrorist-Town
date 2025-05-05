This is an updated version of [Almonger's TTT mod for TF2.](https://github.com/Almoger/TF2-Trouble-In-Terrorist-Town)

## Changelog ##
- Removed all dependencies related to SendProxy. SendProxy is a extremely outdated extension, and constantly causes servers to crash.
- Replaced the "Traitor Outline" effect, previously dependent on SendProxy. It has been replaced by a floating red dot above traitor's heads.
  - The height of the dot can be adjusted manually. The function responsible for it is found inside **setup.sp**.
- Added several sanity checks.

## Dependencies ##
- SourceMod 1.10
- [TF2Items](https://forums.alliedmods.net/showthread.php?p=1050170)
- [MoreColors.inc](https://forums.alliedmods.net/showthread.php?t=185016)

## Configuration ##
Currently there is one configuration file to edit:
* ``ttt_shop.cfg`` - Edit prices for the shop.
