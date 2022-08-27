# frozen_string_literal: true

# This is the class used to set up and use the turing machine.
#
# Use {#event} to create the various transitions. The states are automatically
# inferred to be all the states added through this method.
#
# Use {#initial_state} once to select the initial state, and {#final_state}
# however many times to mark states as final.
#
# The content of the tape can be given upon initializing the machine, through
# the parameter `content`, or with the method {#reset}.
#
# @example A turing machine which prints an "OX" and halts at position 0.
#   m = YATM::Machine.new
#   m.event nil,
#     start:   [:running, "O", :r],
#     running: [:halt, "X", :l]
#   m.initial_state :start
#   m.final_state :halt
#   m.run!
class YATM::Machine
  # The tape over which values can be written and read by the machine.
  attr_reader :tape
  # The state machine associated with this turing machine.
  attr_reader :state_machine
  # @return [Array<Hash>] A record of the transitions undergone by the machine.
  attr_reader :history

  # @param position [Integer] The initial position of the machine's head.
  # @param content [Array] The initial content of the tape, starting from position 0.
  def initialize(position: 0, content: [nil])
    @tape = YATM::Tape.new(content, position: position)
    @state_machine = YATM::StateMachine.new
    @history = []
  end

  # @param state [String, Symbol, Number] The state to be set as the starting state.
  # @return [String, Symbol, Number] The initial state.
  def initial_state(...); @state_machine.initial_state(...); end

  # (see YATM::StateMachine#final_state)
  def final_state(...); @state_machine.final_state(...); end

  # (see YATM::StateMachine#states)
  def states(...); @state_machine.states(...); end

  def events(...); @state_machine.events(...); end

  def event(...); @state_machine.event(...); end

  def reset(...)
    @history = []
    @tape.reset(...)
    @state_machine.reset
  end

  def to_h
    {
      state: @state_machine.current_state,
      final: @state_machine.final_states.include?(@state_machine.current_state),
      position: @tape.pos
    }
  end

  def to_s; to_h.to_s; end

  def to_txt
    <<~TO_S
      ,_______________
      | State Machine
      `---------------
      #{@state_machine}
      ,______
      | Tape
      `------
      #{@tape}
    TO_S
  end

  def step!(n = 1)
    return if n < 1

    (1..n).each do
      result = @state_machine.process!(@tape.read)
      @history << result
      break if result[:final]

      @tape.write result[:write]
      @tape.move result[:move]
    end

    @history.last
  end

  def step(...)
    step!(...) rescue YATM::Error
  end

  def run!(max = Float::INFINITY)
    (1..max).each do
      latest = step!
      break to_h if latest[:final]
    end
  end

  def run(...)
    run!(...) rescue YATM::Error
  end
end
