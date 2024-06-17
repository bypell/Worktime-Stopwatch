#ifndef STOPWATCH_H
#define STOPWATCH_H

#include <godot_cpp/classes/object.hpp>

namespace godot
{

    class Stopwatch : public Object
    {
        GDCLASS(Stopwatch, Object)

    private:
    protected:
        static void _bind_methods();

    public:
        Stopwatch();
        ~Stopwatch();

        // void _process(double delta) override;
    };

}

#endif