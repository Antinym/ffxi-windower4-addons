**Author:**  Aikar<br>
**Modifier:** Antinym<br>
**Version:**  1.0.2.1<br>
**Date:** 2021.2.7<br>

# Logger #

* Outputs all text that appears in the chat log into a text file under `Windower/logs/`.

---

### Settings ###   

* There are some settings that change Logger's output behaviour.

`AddTimestamp` -- prepends a user defined timestamp to each line logged. Defaults to __false__.  

`TimestampFormat` -- the format of the timestamp appended to each line. By default `__%H:%M:%S__`.   

`UseArchiveFolders` -- log files are saved in seperate folders by `player_name/year_month/`.  Defaults to __false__.


Version History
---------------
1.0.2.1
2021.2.7
* Added option to save logs to __player/YYYY_MM/__ folders.

1.0.2.0
2021.2.7
* Stopped logging of duplicate entries.

1.0.1.1  
2015.02.15  
* Added optional timestamp

1.0.1.0  
2015.01.18  
* Stopped logging blocked output.

1.0.0.0  
2015.01.15  
* Initial commit.