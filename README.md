# Worktime-Stopwatch

<p>
 A time tracker plugin for the godot engine made to help you dedicate a set amount of "work time" to your project each day. It can even keep track of the current foreground window and automatically "block" the stopwatch when you get distracted and switch to a non-whitelisted window (this whole activity-limiting feature is Windows-only, at the moment).
</p>
<p>
 This plugin only supports Windows and Linux. It should work on macOS if you comment out a small portion of gdscript code that requires a custom gdextension class that was not built for mac (and maybe remove the /bin folder if there's still an error). You could also build for mac yourself but there's no point since the extra features aren't supported anyways.
</p>

> [!NOTE]
> Most of the plugin's UI elements have a tooltip, just hover over them if you want more info about a setting, etc.

## Installation
1. Download the lastest release for your godot version [here](https://github.com/bypell/Worktime-Stopwatch/releases).
2. Unzip addons.zip and drag the resulting addons folder into your project's root directory.
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
 <img alt="calendar" src="https://github.com/user-attachments/assets/52b19495-bbdf-4018-b18b-ebc02005a6cd">
</p>

## Things to note
- When exporting your game, make sure to exclude the plugin and its related file(s).
  
  ![image](https://github.com/user-attachments/assets/4e6b476c-e3d8-4333-bec0-2a48fd4d717b)

- Also, you may or may not want to exclude the plugin from version control.
  If you're working in a team, you probably should. [You can exclude it locally, without a .gitignore](https://stackoverflow.com/questions/653454/how-do-you-make-git-ignore-files-without-using-gitignore)
- The data for the calendar is kept in a file named "worktime_stopwatch_saved_data.tres" in your project's /addons folder.
- Your settings are kept in a file named "worktime_stopwatch_settings.cfg" which is also in your project's /addons folder.



# Cloning
```
git clone --recurse-submodules https://github.com/bypell/Worktime-Stopwatch.git
```
