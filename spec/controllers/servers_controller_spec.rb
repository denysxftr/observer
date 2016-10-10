RSpec.describe 'ServersController', :vcr do
include ControllerMixin

  let!(:user) { create :user }
  let(:server) { create :server }

  context 'if user signed in' do
    before(:each) do
      post '/sign_in', email: 'example@mail.com', password: 'passw_1234'
    end

    describe 'POST /server/new' do
      let(:server) { Server.first }

      it 'returns server page' do
        post '/server/new', name: 'Try to visit google.com', project_id: '', emails: ['efwe']
        expect(Server.count).to eq 1
        expect(server.valid?).to eq true
        expect(server.name).to eq 'Try to visit google.com'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/server/#{server.id}"
      end
    end

    describe 'GET /servers' do
      let!(:servers) { create_list :server, 5 }

      it 'return page with checks' do
        get '/servers'
        expect(response.errors).to be_empty
        expect(response.status).to eq 200
      end
    end

    describe 'GET /server/id' do
      it 'returns server page' do
        get "/server/#{server.id}"
        expect(response.errors).to be_empty
        expect(response.status).to eq 200
      end
    end

    describe 'GET /server/id/data' do
      context 'if server has states' do
        let(:state) { create :state }

        it 'returns json with data' do
          server.states << state
          get "/server/#{server.id}/data"
          expect(response.errors).to be_empty
          expect(response.content_type).to eq 'application/json'
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json).to_not be_empty
        end
      end

      context 'if server has no states' do
        it 'returns an empty json' do
          get "/server/#{server.id}/data"
          expect(response.errors).to be_empty
          expect(response.content_type).to eq 'application/json'
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['time']).to be_empty
        end
      end
    end

    describe 'POST /server/id' do
      it 'returns server page and updates data' do
        post "/server/#{server.id}", name: 'Try to visit google.com', project_id: ''
        expect(Server.count).to eq 1
        expect(server.reload.valid?).to eq true
        expect(server.reload.name).to eq 'Try to visit google.com'

      end
    end

    describe 'POST /server/id/delete' do
      it 'redirects to main page and deletes server data' do
        post "/servers/#{server.id}/delete"
        expect(Server.count).to eq 0
        expect(response.location).to eq 'http://example.org/'
        expect(response.status).to eq 302
      end
    end
  end

  context "if user didn't sign in" do
    describe 'POST /server/new' do
      it "redirects to sign in page and doesn't create new server" do
        post '/server/new', name: 'Try to visit google.com', project_id: '', emails: ['efwe']
        expect(Server.count).to eq 0
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /servers' do
      let!(:servers) { create_list :server, 5 }

      it 'redirects to sign in page' do
        get '/servers'
        expect(response.errors).to be_empty
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /server/id' do
      it 'redirects to sign in page' do
        get "/server/#{server.id}"
        expect(response.errors).to be_empty
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /server/id/data' do
      it 'redirects to sign in page' do
        get "/server/#{server.id}/data"
        expect(response.errors).to be_empty
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'POST /server/id' do
      it "redirects to sign in page and doesn't update server data" do
        post "/server/#{server.id}", name: 'Try to visit google.com', project_id: ''
        expect(Server.count).to eq 1
        expect(server.reload.name).to_not eq 'Try to visit google.com'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"

      end
    end

    describe 'POST /server/id/delete' do
      it "redirects to sign in page and doesn't delete server data" do
        post "/servers/#{server.id}/delete"
        expect(Server.count).to eq 1
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end
  end
end
