# frozen_string_literal: true

require_relative "tape_errors"

class YATM::Tape
  attr_accessor :pos

  def initialize(...)
    reset(...)
  end

  def reset(content = [nil], position: 0)
    @pos = position
    @p_tape = content
    @n_tape = [nil]
  end

  def read
    tape[table_pos]
  end

  def write(value)
    tape[table_pos] = value
  end

  def move(direction = YATM::NONE)
    case direction
    when YATM::RIGHT
      @pos += 1
      expand if table_pos == tape.size
    when YATM::LEFT
      @pos -= 1
      expand if table_pos > tape.size
    when YATM::NONE
      # do nothing
    else
      raise InvalidMove
    end
  end

  def to_s
    full = @n_tape.reverse + @p_tape
    full.map.with_index do |val, idx|
      cell_txt(val, idx)
    end.join(" ")
        .gsub(/^\[_\] +/, "")
        .gsub(/(\[_\] )*\[_\]\z/, "")
        .gsub(/ \z/, "")
  end

  def to_txt
    full = @n_tape.reverse + @p_tape
    str = ""
    full.each_with_index do |val, idx|
      str += (idx - @n_tape.size).to_s.rjust(4) + " | #{val.inspect}".ljust(8)
      str += " <=" if idx == abs_pos
      str += "\n"
    end

    str
  end

  private

  def cell_txt(val, idx)
    str = idx == @n_tape.size ? "|:| " : ""
    str += idx == abs_pos ? ">|" : "["
    str += val.nil? ? "_" : val.to_s
    str += idx == abs_pos ? "|<" : "]"
    str
  end

  def tape
    @pos >= 0 ?
      @p_tape :
      @n_tape
  end

  def abs_pos
    @pos + @n_tape.size
  end

  def table_pos
    @pos >= 0 ?
      @pos :
      -@pos - 1
  end

  def expand
    current_size = tape.size
    (1..current_size).each { tape << nil }
  end
end
