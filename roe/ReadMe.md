**Author:**  Cair<br>
**Modder:**  Antinym<br>
**Version:**  1.3<br>
**Created:** Oct. 30, 2017<br>
**Updated:** Jan. 12, 2021<br>

### ROE ###

This addon lets you save your currently set objectives to profiles that can be loaded. It can also be configured to remove quests for you. By default, ROE will remove quests that are not in a profile only if their progress is zero. You can customize this to your liking.

### Version History ###
1.3 added unsetting multiple records by id from cmdline
1.2 added setting multiple records by id from cmdline
1.1 added setting/unsetting records by id
1.0 Cair launches stable version.

#### Commands: ####
1. help - Displays this help menu.
2. save <profile name> : saves the currently set ROE to the named profile
3. set <profile name> : attempts to set the ROE objectives in the profile
    - Objectives may be canceled automatically based on settings.
    - The default setting is to only cancel ROE that have 0 progress if space is needed
4. set <list of record ids> : takes ROE objective IDs as arguments (space or comma delimited)
    - `roe set 1000` -- will try to set the "Speak to Fisherman's Guild Master" Objective
    - `roe set 29 31` -- will try to set the "Total Damage I" and "Total Healing I" Objectives
    - set profile rules as defined above apply
5. unset <profile name> : removes currently set objectives
    - if a profile name is specified, every objective in that profile will be removed
    - if a profile name is not specificed, all objectives will be removed (based on your settings)
6. set <list of record ids> : takes ROE objective IDs as arguments (space or comma delimited)
    - `roe unset 1000` will try to unset the "Speak to Fisherman's Guild Master" Objective
    - `roe unset 29,31` will try to unset the "Total Damage I" and "Total Healing I" Objectives
    - unset profile rules as defined above apply
7. settings <settings name> : toggles the specified setting
    * settings:
        * clear : removes objectives if space is needed (default true)
        * clearprogress : remove objectives even if they have non-zero progress (default false)
        * clearall : clears every objective before setting new ones (default false)
8. blacklist [add|remove] <id> : blacklists a quest from ever being removed
    - **_Antinym_** -- I am slowly working on mapping the record id's. Feel free to update the roe_map.lua file and submit a PR.
