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
  end
end
