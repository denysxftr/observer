RSpec.describe CheckPerformWorker, :vcr do
  context 'when all is ok' do
    before do
      expect_any_instance_of(MailerService)
        .to receive(:send_host_success_email).and_return(true)
    end

    let(:check) do
      create :check,
        url: 'http://example.com',
        is_ok: false,
        expected_ip: '93.184.216.34',
        expected_status: 200
    end

    it 'successfully checks url' do
      described_class.new.perform(check.id)
      expect(check.reload.is_ok).to eq true
      expect(Result.count).to eq 1
      expect(Result.first.is_ok).to eq true
    end
  end

  context 'when something wrong' do
    before do
      expect_any_instance_of(MailerService)
        .to receive(:send_host_failed_email).and_return(true)
    end

    context 'when host unreachable' do
      let(:check) { create :check, url: 'http://example.wrong_domain', is_ok: true }

      it 'unsuccessfully checks url' do
        described_class.new.perform(check.id)
        expect(check.reload.is_ok).to eq false
        expect(Result.count).to eq 1
        result = Result.first
        expect(result.is_ok).to eq false
        expect(result.issues['network']).to include('Host is down: Failed to open TCP connection')
      end
    end

    context 'when wrong response status' do
      let(:check) { create :check, url: 'http://google.com/some_404', is_ok: true, expected_status: 200 }

      it 'unsuccessfully checks url' do
        described_class.new.perform(check.id)
        expect(check.reload.is_ok).to eq false
        expect(Result.count).to eq 1
        result = Result.first
        expect(result.is_ok).to eq false
        expect(result.issues).to eq({ 'status' => 'Response status error. Expected 200 got 404.' })
      end
    end

    context 'when wrong A DNS record' do
      let(:check) { create :check, url: 'http://example.com', is_ok: true, expected_ip: '127.0.0.1' }

      it 'unsuccessfully checks url' do
        described_class.new.perform(check.id)
        expect(check.reload.is_ok).to eq false
        expect(Result.count).to eq 1
        result = Result.first
        expect(result.is_ok).to eq false
        expect(result.issues).to eq({ 'ip' => "'A' records error. Expected to have '127.0.0.1' got '93.184.216.34'." })
      end
    end

    context 'when issues with SSL' do
      let(:check) { create :check, url: 'https://example.com', is_ok: true }

      it 'unsuccessfully checks url' do
        expect_any_instance_of(Faraday::Connection).to receive(:get).and_raise(OpenSSL::SSL::SSLError)
        described_class.new.perform(check.id)
        expect(check.reload.is_ok).to eq false
        expect(Result.count).to eq 1
        result = Result.first
        expect(result.is_ok).to eq false
        expect(result.issues).to eq({ 'ssl' => 'SSL error.' })
      end
    end
  end
end
