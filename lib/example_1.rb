# frozen_string_literal: true

# Run with `./bin/console < lib/example_1.rb`

m = YATM::Machine.new
m.event nil,
        start: [:a, 1, :r],
        a: [:b, 1, :r],
        b: [:c, 1, :r],
        c: [:x, nil, :l]
m.event 1,
        x: [:y, 1, :l],
        y: [:z, 2, :l],
        z: [:end, 1, :l]

m.initial_state :start
m.final_state :end

puts m
m.run!
puts m
