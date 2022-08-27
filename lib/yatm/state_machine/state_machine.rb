# frozen_string_literal: true

require_relative "state_machine_errors"
require_relative "event"

class YATM::StateMachine
  # The current state of the state machine
  attr_reader :current_state
  # @return [Array<YATM::StateMachine::Event>] A list of the events that can processed by the machine
  attr_reader :events
  # @return [Array] A list of the final states
  attr_reader :final_states

  def initialize
    @events = {}
    @final_states = []
  end

  def reset
    @current_state = @initial_state
  end

  # @return [String] A string representation of the state machine
  #
  # @example Example output
  #   puts state_machine.to_s
  #
  #   | states:  [:start, :A, :B, :end]
  #   | current: :start
  #   | events: [nil, 0, 1]
  def to_s
    <<~TO_S.chomp
      | states:  #{states}
      | current: #{@current_state}
      | events: #{@events.map(&:name)}
    TO_S
  end

  # @return [Array] The list of all states of the state machine
  def states
    @events.map do |_name, event|
      event.keys + event.map { |_, val| val[:to] }
    end.flatten.uniq
  end

  # @overload initial_state(state)
  #   @param state [#to_s && #to_sym] The state to be set as the starting state
  #   @return [Object] The initial state
  # @overload initial_state
  #   @return [Object] The initial state
  #
  # @see states
  def initial_state(state = nil)
    return @initial_state if state.nil?

    @initial_state = self.class.statify(state)
    @current_state = @initial_state
  end

  # @param states [#to_s && #to_sym] The state or array of states to be marked
  #   as final states
  # @return [Array] The complete list of final states
  def final_state(*states)
    states.each do |state|
      (@final_states << self.class.statify(state)).uniq!
    end
    @final_states
  end

  # @param name [Object] The name of the event.
  #
  #   Note that this is also the value which, when read from the tape, will
  #   trigger the processing of this event.
  # @param **transitions [Hash | Hash[, Hash...]] One or more transitions.
  #
  #   Transitions can be of the following forms:
  #   - `state1 => [state2, value, movement]`
  #   - `state1 => [state2, value]`
  #   - `state1 => [state2]`
  #   - `state1 => state2`
  #   On all cases, the machine is going from `state1` to `state2`, writing
  #   `value` on the current position of the tape, and moving the head in the
  #   direction specified by `movement`.
  # @return [YATM::StateMachine::Event] The event object creared
  def event(name, **transitions)
    @events[name] = YATM::Event.new(name, **transitions)
  end

  # @param value [Object] Tape value to be processed (trigger corresponding
  #   event) by the machine
  # @return [Hash | nil] A representation of the transition which was triggered,
  #   or nil if none was
  def process(value)
    process!(value)
  rescue StateMachineError
    nil
  end

  # @param value [Object] Tape value to be processed (trigger corresponding
  #   event) by the machine
  # @return [Hash] A representation of the transition which was triggered
  # @raise [InitialStateNotSet] No initial state was set. See {initial_state}
  # @raise [InvalidEvent] There is no event registered under the given value
  # @raise [InvalidTransition] There is an event registered under the given
  #   value, but it contains no transitions from the machine's current state
  def process!(value)
    return { final: @current_state } if @final_states.include?(@current_state)
    raise InitialStateNotSet unless @current_state
    raise InvalidEvent, value unless (event = @events[value])
    raise InvalidTransition.new(@current_state, event) unless (
      transition = event[@current_state] || event[YATM::ANY]
    )

    @current_state = transition[:to] unless transition[:to] == YATM::SAME
    transition
  end

  class << self
    # @param state [#to_s && #to_sym] The object to be statified
    # @return [Symbol] The object's statified form
    # @raise [InvalidState] The object given could not be statified
    def statify!(state)
      raise InvalidState, state unless state.respond_to?(:to_s)

      state = state.to_s
      raise InvalidState, state unless state.respond_to?(:to_sym)

      state.to_sym
    end

    # @param state [#to_s && #to_sym] The object to be statified
    # @return [Symbol | nil] If the object could be statified, it's statified
    #   form. Nil otherwise
    def statify(state)
      statify!(state) rescue StateMachineError
    end
  end
end
