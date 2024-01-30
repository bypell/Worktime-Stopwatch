#!/usr/bin/env python
import os
import sys

env = SConscript("gdextension_src/godot-cpp/SConstruct")

env.Append(LIBS = ['User32'])


# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["gdextension_src/cpp_src/"])
sources = Glob("gdextension_src/cpp_src/*.cpp")

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "addons/worktime_stopwatch/gdextension/bin/libwstopwatchutils.{}.{}.framework/libgdexample.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "addons/worktime_stopwatch/gdextension/bin/libwstopwatchutils{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
