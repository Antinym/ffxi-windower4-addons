**Author:** Giuliano Riccio
**Modifier:** Antinym
**Version:** v 1.20210114

# Enternity #

Enters "Enter" automatically when prompted during a cutscene or when talking to NPCs. It will not skip choice dialog boxes. It will not skip any line with green colored text. 

There are two boolean settings which control how enternity functions.   
**enabled** [default is True] basically turns enternity on and off.   
**skipall** [default is False] allows the skipping of lines with green text.

There is a list of aliases for these settings for convenience. Look for the _lookups table in the enternity.lua file.  

## shortcuts ##

Enternity creates four aliases for ease of use and functionality.
* _eon_       -- enables enternity. (Default state on load)
* _eoff_      -- disables enternity's "Enter" actions
* _eskip_     -- toggles if enternity stops at lines with green text (the default action)
* _enternity_ -- alias for the enternity toggle function which takes two arguments
    * _setting_ -- the name of the setting you want to change
    * _value_   -- (optional) boolean value to set. If omitted the current value will be set to the opposite value.  

```Shell 
enternity enabled on        --  disables enternity
enternity enabled off       --  enables enternity  
enternity enabled           --  toggles the current state  
enternity skipall [on/off]  --  enable/disable/toggle maximum skippage
```  

_If a value is given, it's only checked against this 'False' list {'false','f','nil','off','end'}. Any other value will be treated as True._

----

##Changelog##
### v1.20210114 ###
* **change:** Rewrote to enable/disable enternity without unloading the addon. Also rewrote how the addon toggles settings.

### v1.20200927 ###
* **change:** Added ability to skip even more dialog (skips almost all dialog breaks now).
* **change:** Added alias shortcuts to toggle enhanced skippage. Shortcut executes this function: `lua i enternity skipall`.
* **change:** Added alias shortcuts to load/unload enternity.

### v1.20130620 ###
* **fix:** Sentences that contain items will not be skipped.
* **fix:** Added NPCs exceptions.

### v1.20130607 ###
* **change:** Changed from artificial button press to ignoring the stop. Allows to type text freely while it goes through cutscenes.

### v1.20130606 ###
* First release.
