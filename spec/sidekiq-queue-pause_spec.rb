require "spec_helper"

describe Sidekiq::QueuePause do
  describe Sidekiq::QueuePause::PausingFetch do
    let(:queue_name) { "some_queue" }
    let(:config) { {queues: [queue_name], strict: true} }

    subject(:pausing_fetch) { described_class.new(config) }

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
      let(:conn) { double("redis connection", read_timeout: 5, blocking_call: queue_and_work, brpop: queue_and_work) }
      let(:job) { {queue: "some_queue", retry: true} }
      let(:queue) { "queue:#{queue_name}" }
      let(:queue_and_work) { [queue, job.to_json] }

      it "does not raise a `NoMethodError: undefined method `redis' for nil:NilClass` due to lack of `config`" do
        allow(config).to receive(:redis).and_yield(conn)
        allow(pausing_fetch).to receive(:redis).and_yield(conn)

        expect(described_class::UnitOfWork).to receive(:new).with(queue, job.to_json, config).and_call_original
        #expect(conn).to receive(:blocking_call).with(conn.read_timeout + described_class::TIMEOUT, "brpop", queue, described_class::TIMEOUT)
        expect(conn).to receive(:brpop).with(queue)
        expect(conn).to receive(:rpush).with(queue, job.to_json)

        unit_of_work = pausing_fetch.retrieve_work_for_queues(queue)

        expect { unit_of_work.requeue }.to_not raise_error
      end
    end
  end
end
