# frozen_string_literal: true

# Run with `./bin/console < lib/example_2.rb`

# This machine reads from position 0 towards the right until it finds a blank
# value, then prints the total sum of numbers found (up to 3), and halts.
#
# It will halt on state `halt` if all goes well, or on state `overflow` in case
# the sum goes over 3.

ANY  = YATM::ANY  # from any state
SAME = YATM::SAME # to the same state as before
NO   = YATM::SAME # don't write anything

m = YATM::Machine.new(content: [1, 2])
m.event 0,
        ANY => [SAME, NO, :r]
m.event 1,
        _0: [:_1, NO, :r],
        _1: [:_2, NO, :r],
        _2: [:_3, NO, :r],
        _3: :overflow
m.event 2,
        _0: [:_2, NO, :r],
        _1: [:_3, NO, :r],
        _2: :overflow,
        _3: :overflow
m.event nil,
        _0: [:halt, 0],
        _1: [:halt, 1],
        _2: [:halt, 2],
        _3: [:halt, 3]
m.initial_state :_0
m.final_state :halt, :overflow

m.run!
puts m.tape
puts m

m.reset [1, 0, 1]
m.run!
puts m.tape
puts m

m.reset [1, 2, 1]
m.run!
puts m.tape
puts m
