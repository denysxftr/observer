RSpec.describe ServerCurrentCheckWorker do

  context 'if had no issues previously' do
    let!(:server) { create :server, issues: [] }

      context 'when all is ok' do
        before do
          expect_any_instance_of(MailerService)
            .to_not receive(:send_server_bad)
        end

        let(:state1) { create :state }
        let(:state2) { create :state }

        it 'checks server with success result' do
          server.states << state1
          server.states << state2
          described_class.new.perform(server.reload.id)
          expect(server.reload.is_ok).to eq true
          expect(server.reload.issues).to be_empty
        end
      end

      context 'when something wrong' do
        before do
          expect_any_instance_of(MailerService)
            .to receive(:send_server_bad).and_return(true)
        end

        context 'when cpu is overloaded' do
          let(:state1) { create :state, cpu_load: 95 }
          let(:state2) { create :state, cpu_load: 99 }

          it 'checks server with fault result' do
            server.states << state1
            server.states << state2
            described_class.new.perform(server.id)
            expect(server.reload.is_ok).to eq false
            expect(server.reload.issues.count).to eq 1
            expect(server.reload.issues).to eq [:cpu_high]
          end
        end

        context 'when ram is overloaded' do
          let(:state1) { create :state, ram_usage: 95 }
          let(:state2) { create :state, ram_usage: 99 }

          it 'checks server with fault result (ram)' do
            server.states << state1
            server.states << state2
            described_class.new.perform(server.id)
            expect(server.reload.is_ok).to eq false
            expect(server.reload.issues.count).to eq 1
            expect(server.reload.issues).to eq [:ram_high]
          end
        end

        context 'when swap is overloaded' do
          let(:state1) { create :state, swap_usage: 55 }
          let(:state2) { create :state, swap_usage: 41 }

          it 'checks server with fault result (swap)' do
            server.states << state1
            server.states << state2
            described_class.new.perform(server.id)
            expect(server.reload.is_ok).to eq false
            expect(server.reload.issues.count).to eq 1
            expect(server.reload.issues).to eq [:swap_high]
          end
        end
      end
  end

  context 'if had issues previously' do
    let!(:server) { create :server_with_isues }

    context 'if has no problems' do
      before do
        expect_any_instance_of(MailerService)
          .to_not receive(:send_server_bad)
      end

      let(:state1) { create :state }
      let(:state2) { create :state }

      it 'successfully checks server state' do
        server.states << state1
        server.states << state2
        described_class.new.perform(server.id)
        expect(server.reload.is_ok).to eq true
        expect(server.reload.issues).to be_empty
      end
    end

    context 'if has problems' do
      context 'when cpu is overloaded' do
        let(:state1) { create :state, cpu_load: 81 }
        let(:state2) { create :state, cpu_load: 82 }

        it 'checks server with fault result' do
          server.states << state1
          server.states << state2
          described_class.new.perform(server.id)
          expect(server.reload.is_ok).to eq false
          expect(server.reload.issues.count).to eq 1
          expect(server.reload.issues).to eq [:cpu_high]
        end
      end

      context 'when ram is overloaded' do
        let(:state1) { create :state, ram_usage: 87 }
        let(:state2) { create :state, ram_usage: 89 }

        it 'checks server with fault result (ram)' do
          server.states << state1
          server.states << state2
          described_class.new.perform(server.id)
          expect(server.reload.is_ok).to eq false
          expect(server.reload.issues.count).to eq 1
          expect(server.reload.issues).to eq [:ram_high]
        end
      end

      context 'when swap is overloaded' do
        let(:state1) { create :state, swap_usage: 31 }
        let(:state2) { create :state, swap_usage: 37 }

        it 'checks server with fault result (swap)' do
          server.states << state1
          server.states << state2
          described_class.new.perform(server.id)
          expect(server.reload.is_ok).to eq false
          expect(server.reload.issues.count).to eq 1
          expect(server.reload.issues).to eq [:swap_high]
        end
      end
    end
  end
end
