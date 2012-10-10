require "digest/md5"
require "socket"

module Moped
  module BSON
    class ObjectId
      include Comparable

      class << self
        def from_string(string)
          raise Errors::InvalidObjectId.new(string) unless legal?(string)
          from_data [string].pack("H*")
        end

        def from_time(time)
          from_data [time.to_i].pack("Nx8")
        end

        def legal?(str)
          /\A\h{24}\Z/ === str.to_s
        end

        def from_data(data)
          id = allocate
          id.send(:data=, data)
          id
        end
      end

      def ===(other)
        return to_str === other.to_str if other.respond_to?(:to_str)
        super
      end

      def data
        # If @data is defined, then we know we've been loaded in some
        # non-standard way, so we attempt to repair the data.
        repair! @data if defined? @data

        @raw_data ||= @@generator.next
      end

      def ==(other)
        BSON::ObjectId === other && data == other.data
      end
      alias eql? ==

      def <=>(other)
        data <=> other.data
      end

      def hash
        data.hash
      end

      def to_s
        data.unpack("H*")[0]
      end
      alias :to_str :to_s

      def inspect
        to_s.inspect
      end

      def to_json(*args)
        "{\"$oid\": \"#{to_s}\"}"
      end

      # Return the UTC time at which this ObjectId was generated. This may
      # be used instread of a created_at timestamp since this information
      # is always encoded in the object id.
      def generation_time
        Time.at(data.unpack("N")[0]).utc
      end

      class << self
        def __bson_load__(io)
          from_data(io.read(12))
        end
      end

      def __bson_dump__(io, key)
        io << Types::OBJECT_ID
        io << key.to_bson_cstring
        io << data
      end

      # @api private
      class Generator
        def initialize
          # Generate and cache 3 bytes of identifying information from the current
          # machine.
          @machine_id = Digest::MD5.digest(Socket.gethostname).unpack("N")[0]

          @mutex = Mutex.new
          @counter = 0
        end

        # Return object id data based on the current time, incrementing the
        # object id counter.
        def next
          @mutex.lock
          begin
            counter = @counter = (@counter + 1) % 0xFFFFFF
          ensure
            @mutex.unlock rescue nil
          end

          generate(Time.new.to_i, counter)
        end

        # Generate object id data for a given time using the provided +counter+.
        def generate(time, counter = 0)
          [time, @machine_id, Process.pid, counter << 8].pack("N NX lXX NX")
        end
      end

      @@generator = Generator.new

      # @private
      def marshal_dump
        data
      end

      # @private
      def marshal_load(data)
        self.data = data
      end

      private

      # Attempts to repair ObjectId data marshalled in previous formats.
      #
      # The first check covers an ObjectId generated by the mongo-ruby-driver.
      #
      # The second check covers an ObjectId generated by moped before a custom
      # marshal strategy was added.
      def repair!(data)
        if data.is_a?(Array) && data.size == 12
          self.data = data.pack("C*")
        elsif data.is_a?(String) && data.size == 12
          self.data = data
        else
          raise TypeError, "Could not convert #{data.inspect} into an ObjectId"
        end
      end

      # Private interface for setting the internal data for an object id.
      def data=(data)
        @raw_data = data
      end
    end
  end
end
