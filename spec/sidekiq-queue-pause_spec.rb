require "spec_helper"

describe Sidekiq::QueuePause do
  describe Sidekiq::QueuePause::PausingFetch do
    describe "#unpause_queues_cmd" do
      let(:queuename) { "some_queue" }
      let(:config) { {queues: [queuename], strict: true} }
      let(:pausing_fetch) { described_class.new(config) }

      context "with Sidekiq > 6.5.6 the queues list can contain Hashes" do
        let(:queue_list) { ["queue:#{queuename}", {timeout: 2}] }

        before { allow(pausing_fetch).to receive(:queues_cmd).and_return(queue_list) }

        it "does not checked whether the Hash is paused" do
          expect(Sidekiq::QueuePause).to receive(:paused?).with(queuename, Sidekiq::QueuePause.process_key).and_return(false)

          expect(pausing_fetch.unpaused_queues_cmd).to match_array(queue_list)
        end
      end

      context "with Sidekiq < 6.5.6 the queues list can contain an Integer" do
        let(:queue_list) { ["queue:#{queuename}", 2] }

        before { allow(pausing_fetch).to receive(:queues_cmd).and_return(queue_list) }

        it "does not check whether the Integer is paused" do
          expect(Sidekiq::QueuePause).to receive(:paused?).with(queuename, Sidekiq::QueuePause.process_key).and_return(false)

          expect(pausing_fetch.unpaused_queues_cmd).to match_array(queue_list)
        end
      end
    end
  end
end
