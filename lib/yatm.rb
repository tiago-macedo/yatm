# frozen_string_literal: true

require_relative "yatm/version"
require_relative "yatm/tape/tape"
require_relative "yatm/state_machine/state_machine"
require_relative "yatm/machine/machine"

# This is the main module.
module YATM
  ANY   = :*
  SAME  = :_
  LEFT  = :l
  RIGHT = :r
  NONE  = nil
end
