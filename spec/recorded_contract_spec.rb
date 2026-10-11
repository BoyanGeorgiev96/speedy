# frozen_string_literal: true

require_relative 'support/recorded_contracts'

RSpec.describe 'Committed Speedy VCR contracts', :replay do
  include SpeedyRecordedContracts

  recordings = Dir[File.join(__dir__, 'fixtures/vcr_cassettes/**/*.yml')]
  raise 'No committed VCR recordings found' if recordings.empty?

  recordings.each do |path|
    cassette = path.delete_prefix(File.join(__dir__, 'fixtures/vcr_cassettes/')).delete_suffix('.yml')
    it "replays every interaction in #{cassette} through public methods" do
      interactions = read_recording(path)
      expect(interactions).not_to be_empty
      VCR.use_cassette(cassette, record: :none, match_requests_on: %i[method replay_uri replay_body],
                                 allow_unused_http_interactions: false) do
        interactions.each { |interaction| replay_interaction(interaction) }
      end
    end
  end

  it 'blocks unmatched requests without a cassette' do
    expect { Net::HTTP.get(URI('https://unmatched.invalid/no-recording')) }
      .to raise_error(RuntimeError, /Replay-only mode blocks/)
  end

  it 'blocks unmatched requests in an existing cassette' do
    VCR.use_cassette('speedy_api/countries', record: :none) do
      expect { Net::HTTP.get(URI('https://unmatched.invalid/existing')) }
        .to raise_error(RuntimeError, /Replay-only mode blocks/)
    end
  end

  it 'blocks requests even if a caller overrides the record mode' do
    VCR.use_cassette('never_record_in_ci', record: :all) do
      expect { Net::HTTP.get(URI('https://unmatched.invalid/override')) }
        .to raise_error(RuntimeError, /Replay-only mode blocks/)
    end
  end

  it 'blocks requests for missing cassettes' do
    VCR.use_cassette('missing_ci_recording', record: :none) do
      expect { Net::HTTP.get(URI('https://unmatched.invalid/missing')) }
        .to raise_error(RuntimeError, /Replay-only mode blocks/)
    end
  end

  it 'does not exempt localhost from the replay-only firewall' do
    expect(WebMock.net_connect_allowed?('http://127.0.0.1:1/no-recording')).to be false
    expect { Net::HTTP.get(URI('http://127.0.0.1:1/no-recording')) }
      .to raise_error(RuntimeError, /Replay-only mode blocks/)
  end

  it 'blocks requests even when VCR is turned off' do
    VCR.turned_off do
      expect { Net::HTTP.get(URI('http://127.0.0.1:1/no-recording')) }
        .to raise_error(RuntimeError, /Replay-only mode blocks/)
    end
  end
end
