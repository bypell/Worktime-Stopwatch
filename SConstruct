#!/usr/bin/env python

env = SConscript("godot-cpp/SConstruct")

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

if env["platform"] == "windows":
    env.Append(LIBS = ['user32'])

library = env.SharedLibrary(
        "addons/worktime_stopwatch/bin/libworktime-stopwatch{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)