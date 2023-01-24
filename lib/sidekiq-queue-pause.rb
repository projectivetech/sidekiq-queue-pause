require "sidekiq"
require "sidekiq/fetch"

module Sidekiq
  module QueuePause
    PREFIX = "queue_pause"

    class << self
      attr_accessor :retry_after
      attr_writer :process_key

      def process_key(&block)
        if block
          @process_key = block
        else
          @process_key.is_a?(Proc) ? @process_key.call : @process_key
        end
      end

      def pause(queue, pkey = nil)
        Sidekiq.redis { |it| it.set rkey(queue, pkey), true }
      end

      def unpause(queue, pkey = nil)
        Sidekiq.redis { |it| it.del rkey(queue, pkey) }
      end

      def paused?(queue, pkey = nil)
        Sidekiq.redis { |it| it.exists? rkey(queue, pkey) }
      end

      def unpause_all
        Sidekiq.redis { |it| it.keys("#{PREFIX}:*").each { |k| it.del k } }
      end

      private

      def rkey(queue, pkey)
        pkey ? "#{PREFIX}:#{queue}:#{pkey}" : "#{PREFIX}:#{queue}"
      end
    end

    class PausingFetch < Sidekiq::BasicFetch
      def retrieve_work
        qcmd = unpaused_queues_cmd

        if qcmd.size > 1
          retrieve_work_for_queues qcmd
        else
          sleep(Sidekiq::QueuePause.retry_after || Sidekiq::BasicFetch::TIMEOUT)
          nil
        end
      end

      def retrieve_work_for_queues(qcmd)
        work = Sidekiq.redis { |conn| conn.brpop(*qcmd) }
        UnitOfWork.new(*work) if work
      end

      # Returns the list of unpause queue names.
      #
      # @return [Array<String>] The list of unpaused queue names.
      def unpaused_queues_cmd
        queues = queues_cmd
        queues.reject do |q|
          next if q.is_a?(Integer)
          next if q.is_a?(Hash)

          Sidekiq::QueuePause.paused?(q.gsub("queue:", ""), Sidekiq::QueuePause.process_key)
        end
      end
    end
  end

  class Queue
    def pause(pkey = nil)
      Sidekiq::QueuePause.pause(name, pkey)
    end

    def unpause(pkey = nil)
      Sidekiq::QueuePause.unpause(name, pkey)
    end

    def paused?(pkey = nil)
      Sidekiq::QueuePause.paused?(name, pkey)
    end
  end
end
