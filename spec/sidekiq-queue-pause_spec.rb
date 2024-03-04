require "spec_helper"

describe Sidekiq::QueuePause do
  describe Sidekiq::QueuePause::PausingFetch do
    let(:queue_name) { "some_queue" }
    let(:logger) { double("logger") }
    let(:job) { {queue: "some_queue", retry: true} }
    let(:queue) { "queue:#{queue_name}" }
    let(:queue_and_work) { [queue, job.to_json] }
    let(:conn) { double("redis connection", read_timeout: 5, blocking_call: queue_and_work, brpop: queue_and_work) }
    let(:config) { OpenStruct.new(queues: [queue_name], strict: true, logger: logger, redis: conn) }

    subject(:pausing_fetch) { described_class.new(config) }

    describe "instance methods from Component" do
      it "responds to `logger`" do
        expect(pausing_fetch).to respond_to(:logger)
      end

      it "responds to `redis`" do
        expect(pausing_fetch).to respond_to(:redis)
      end

      it "config is not a `#{Hash}`" do
        expect(pausing_fetch.config).not_to be_a(Hash)
      end
    end

    describe "#unpause_queues_cmd" do
      context "with Sidekiq > 6.5.6 the queues list can contain Hashes" do
        let(:queue_list) { ["queue:#{queue_name}", {timeout: 2}] }

        before { allow(pausing_fetch).to receive(:queues_cmd).and_return(queue_list) }

        it "does not checked whether the Hash is paused" do
          expect(Sidekiq::QueuePause).to receive(:paused?).with(queue_name, Sidekiq::QueuePause.process_key).and_return(false)

          expect(pausing_fetch.unpaused_queues_cmd).to match_array(queue_list)
        end
      end

      context "with Sidekiq < 6.5.6 the queues list can contain an Integer" do
        let(:queue_list) { ["queue:#{queue_name}", 2] }

        before { allow(pausing_fetch).to receive(:queues_cmd).and_return(queue_list) }

        it "does not check whether the Integer is paused" do
          expect(Sidekiq::QueuePause).to receive(:paused?).with(queue_name, Sidekiq::QueuePause.process_key).and_return(false)

          expect(pausing_fetch.unpaused_queues_cmd).to match_array(queue_list)
        end
      end
    end

    describe "reenqueueing a unit of work" do

      it "does not raise a `NoMethodError: undefined method `redis' for nil:NilClass` due to lack of `config`" do
        allow(Sidekiq).to receive(:redis).and_yield(conn)

        expect(described_class::UnitOfWork).to receive(:new).with(queue, job.to_json, Sidekiq).and_call_original
        #expect(conn).to receive(:blocking_call).with(conn.read_timeout + described_class::TIMEOUT, "brpop", queue, described_class::TIMEOUT)
        expect(conn).to receive(:brpop).with(queue)
        expect(conn).to receive(:rpush).with(queue, job.to_json)

        unit_of_work = pausing_fetch.retrieve_work_for_queues(queue)

        expect { unit_of_work.requeue }.to_not raise_error
      end
    end
  end
end
