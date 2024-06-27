#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

if env["platform"] == "windows":
    env.Append(LIBS = ['user32'])

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "addons/worktime_stopwatch/bin/worktime-stopwatch-lib.{}.{}.framework/worktime-stopwatch-lib.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "addons/worktime_stopwatch/bin/worktime-stopwatch-lib{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)