module Batsir
  module Acceptors
    class Acceptor
      include Celluloid

      attr_accessor :stage_name
      attr_accessor :transformer_queue

      def initialize(options = {})
        options.each do |option, value|
          self.send("#{option}=", value)
        end
        @transformer_queue = []
      end

      def add_transformer(transformer)
        @transformer_queue << transformer
      end

      # This method is called automatically when the stage is
      # started, it is here that you set up the accepting
      # logic. Make sure that somewhere within this logic
      # the #start_filter_chain(msg) is called to start
      # actual processing
      #
      # Note that this method will be invoked asynchronously
      # using the Celluloid actor semantics.
      def start

      end

      # When a message is accepted by an Acceptor, this method
      # should be invoked with the received payload to start
      # processing of the filter chain
      def start_filter_chain(message)
        klazz = Batsir::Registry.get(stage_name)
        transformer_queue.each do |transformer|
          message = transformer.transform(message)
        end
        klazz.perform_async(message) if klazz
      end
    end
  end
end
