# frozen_string_literal: true

# Run with `./bin/console < lib/yatm/state_machine/example.rb`

sm = YATM::StateMachine.new
sm.initial_state "start"

sm.event 0, start: [:a, 1]
sm.event 1, a: [:b, 2, :r]
sm.event 2, b: [:c, 3, :l]
sm.event 3, c: [:a, 1, :r]
sm.event false,
         a: :finish,
         b: :finish,
         c: :finish

puts sm.events

sm.current_state
sm.process! 0
sm.process! 1
sm.process! 2
sm.process! 3
"attempt invalid event with #process:"
sm.process 4
sm.current_state
sm.process false
"attempt invalid event with #process!:"
sm.process! 4
