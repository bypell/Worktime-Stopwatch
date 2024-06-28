#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

if env["platform"] == "windows":
    env.Append(LIBS = ['user32'])

library = env.SharedLibrary(
        "addons/worktime_stopwatch/bin/worktime-stopwatch{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

# if env["platform"] == "macos":
#     library = env.SharedLibrary(
#         "addons/worktime_stopwatch/bin/worktime-stopwatch.{}.{}.framework/worktime-stopwatch.{}.{}".format(
#             env["platform"], env["target"], env["platform"], env["target"]
#         ),
#         source=sources,
#     )
# else:
#     library = env.SharedLibrary(
#         "addons/worktime_stopwatch/bin/worktime-stopwatch{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
#         source=sources,
#     )

Default(library)