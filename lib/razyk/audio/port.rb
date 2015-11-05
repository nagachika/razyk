# coding: utf-8

require "razyk/audio/player"

module RazyK::Audio
  class Port
    def initialize
      @player = nil
      @note_length = nil
      @octave = nil
    end

    def write(s)
      bytes = s.unpack("C*")
      if @player.nil?
        @player = RazyK::Audio::Player.new(tempo: bytes.shift)
      end
      bytes.each do |b|
        if @note_length and @octave
          @player.play(@note_length, @octave, b)
          @note_length = nil
          @octave = nil
        elsif @note_length
          @octave = b
        else
          @note_length = b
        end
      end
      s
    end

    def close_write
      @player.stop
    end
  end
end
