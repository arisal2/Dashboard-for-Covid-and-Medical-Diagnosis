# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarketwebMailerJob, type: :job do
  describe '#perform' do
    context 'when jobs are executed' do
      include ActiveJob::TestHelper

      subject(:job) { described_class.perform_later }

      it 'queues the job' do
        expect { job }.to have_enqueued_job(described_class)
          .on_queue('default')
      end

      it 'is in urgent queue' do
        expect(MarketwebMailerJob.new.queue_name).to eq('default')
      end

      after do
        clear_enqueued_jobs
        clear_performed_jobs
      end
    end
  end
end
