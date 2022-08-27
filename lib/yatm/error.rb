# frozen_string_literal: true

# @abstract Subclass and override {#text} to set the default error message.
class YATM::Error < StandardError
  def text
    raise NotImplementedError
  end

  def to_s
    super == self.class.to_s ? text : super
  end
end
