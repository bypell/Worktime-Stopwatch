#!/usr/bin/env python

env = SConscript("godot-cpp/SConstruct")

env.Append(CPPPATH=["src/"])
sources = Glob("src/*.cpp")

if env["platform"] == "windows":
    env.Append(LIBS = ['user32'])


if env["platform"] == "macos":
    library = env.SharedLibrary(
        "addons/worktime_stopwatch/bin/libworktime-stopwatch.{}.{}.framework/libworktime-stopwatch.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "addons/worktime_stopwatch/bin/libworktime-stopwatch{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )


Default(library)