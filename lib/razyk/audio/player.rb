# coding: utf-8

require "coreaudio"
require "thread"

module RazyK::Audio
  class Player
    def initialize(tempo: 4)
      @tempo = 4
      @dev = CoreAudio.default_output_device
      @buf = @dev.output_buffer(1024)
      @beat_samples = (@dev.nominal_rate / (@tempo * 4)).floor
      @beat_bufs = Hash.new { |h, k| h[k] = NArray.sint(@beat_samples * (k+1)) }
      @samples = 0
      @queue = Queue.new
      @thread = nil
    end

    def play(length, octave, note)
      unless (0..8).include?(octave)
        octave = 4
      end
      unless (0..11).include?(note)
        note = 0
      end
      @queue.push([length, octave, note])
      if @thread.nil? or not(@thread.status)
        @thread = Thread.start{ run }
      end
    end

    def stop
      @queue.push(nil)
      @thread.join if @thread
    end

    def run
      begin
        @buf.start
        while (tuple = @queue.pop)
          length, octave, note = tuple
          wav = @beat_bufs[length]
          if octave | note == 0
            wav.fill!(0)
          else
            freq = (440.0 * (2 ** (octave-4))) # An
            freq *= 2 ** ((note-9)/12.0)
            phase = Math::PI * 2 * freq / @dev.nominal_rate
            breath = (@beat_samples * 0.2).round
            eot = wav.size - breath
            eot.times do |j|
              wav[j] = (0.7 * Math.sin(phase*(@samples+j)) * 0x7FFF).round
            end
            breath.times do |j|
              wav[eot+j] = 0
            end
            @samples += wav.size
            @buf << wav
          end
        end
      rescue
        puts $!, $@
      ensure
        @buf.stop
      end
    end
  end
end
