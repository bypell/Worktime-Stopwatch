# Worktime-Stopwatch

<p>
 a time tracker plugin for the godot engine made to help you dedicate a set amount of "work time" to your project each day. It can even keep track of the current foreground window and automatically stop the stopwatch when you get sidetracked and switch to a non-whitelisted window (this feature is Windows-only at the moment).
</p>
<p>
 This plugin only supports Windows and Linux. It can likely work on macOS if you comment out a small portion of gdscript code that requires a custom gdextension class that was not built for mac (and maybe remove the /bin folder if there's still an error).
</p>

> [!NOTE]
> Most UI elements have a tooltip, just hover over them if you want more info about a setting, etc.

## Screenshots
<p>
 <img alt="stopwatch dock" src="https://github.com/user-attachments/assets/d6eb84ef-9c70-4d0a-89d7-734990a630bf">
</p>
<p>
 <img alt="calendar" src="https://github.com/user-attachments/assets/d7afba01-a7be-4d51-9fe7-fe41e94d755f">
</p>
<p>
 <img alt="calendar" src="https://github.com/user-attachments/assets/52b19495-bbdf-4018-b18b-ebc02005a6cd">
</p>

# Cloning
```
git clone --recurse-submodules https://github.com/bypell/Worktime-Stopwatch.git
```
