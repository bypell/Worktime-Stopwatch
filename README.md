# Worktime-Stopwatch

<p>
 A time tracker plugin for the godot engine made to help you dedicate a set amount of "work time" to your project each day. 
</p>
<p>
 It can even keep track of the current foreground window and automatically "block" the stopwatch when you get distracted and switch to a non-whitelisted window (this is Windows-only, at the moment).
</p>
<p>
 This plugin only supports Windows and Linux. It should work on macOS if you comment out some code in stopwatch.gd. You could also instead build for mac yourself but there's no point in doing that since the activity limiting feature isn't supported anyway.
</p>

> [!NOTE]
> Most of the plugin's UI elements have a tooltip, just hover over them if you want more info about a setting, etc. This includes one or more labels that you wouldn't think have a tooltip.

## Installation
Also available in the asset library!

Manual way:
1. Download the latest release for your godot version [here](https://github.com/bypell/Worktime-Stopwatch/releases).
2. Unzip WorktimeStopwatch.zip and drag the addons folder into your project's root directory.
3. Restart the editor.
4. Enable the plugin in Project settings -> plugins

## Screenshots
<p>
 <img alt="stopwatch dock" src="https://github.com/user-attachments/assets/d6eb84ef-9c70-4d0a-89d7-734990a630bf">
</p>
<p>
 <img alt="calendar" src="https://github.com/user-attachments/assets/d7afba01-a7be-4d51-9fe7-fe41e94d755f">
</p>
<p>
 <img alt="calendar" src="https://github.com/user-attachments/assets/ddfa27b0-0d68-40e5-abdc-b12c914cd014">
</p>

## Things to note
- When exporting your game, make sure to exclude the plugin and its related file(s).
  
  ![image](https://github.com/user-attachments/assets/4e6b476c-e3d8-4333-bec0-2a48fd4d717b)

- Also, you may or may not want to exclude the plugin from version control.
  If you're working in a team, you probably should. [You can exclude it locally, without a .gitignore](https://stackoverflow.com/questions/653454/how-do-you-make-git-ignore-files-without-using-gitignore)
- The data for the calendar is kept in a file named "worktime_stopwatch_saved_data.tres" in your project's /addons folder.
- Your settings are kept in a file named "worktime_stopwatch_settings.cfg" which is also in your project's /addons folder.



# Cloning and building godot-cpp + gdextension
```
git clone --recurse-submodules https://github.com/bypell/Worktime-Stopwatch.git
cd Worktime-Stopwatch
cd godot-cpp
scons
cd ..
scons
```
