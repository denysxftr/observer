RSpec.describe 'ServersController', :vcr do
include ControllerMixin

  let!(:user) { create :user }

  before(:each) do
    post '/sign_in', email: 'example@mail.com', password: 'passw_1234'
    @server = FactoryGirl.create(:server)
  end

  describe 'POST /server/new' do
    let(:server) { Server.all[1] }

    it 'returns server page' do
      post '/server/new', name: 'Try to visit google.com', project_id: '', emails: ['efwe']
      expect(Server.count).to eq 2
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
      get "/server/#{@server.id}"

      expect(response.errors).to be_empty
      expect(response.status).to eq 200
    end
  end

  describe 'GET /server/id/data' do
    #create states?
    it 'returns json with data' do
      get "/server/#{@server.id}/data"

      expect(response.errors).to be_empty
      expect(response.content_type).to eq 'application/json'
      expect(response.status).to eq 200
    end
  end

  describe 'POST /server/id' do
    it 'returns server page and updates data' do
      post "/server/#{@server.id}", name: 'Try to visit google.com', project_id: ''

      expect(Server.count).to eq 1
      expect(@server.reload.valid?).to eq true
      expect(@server.reload.name).to eq 'Try to visit google.com'

    end
  end

  describe 'POST /server/id/delete' do
    it 'redirects to main page and deletes server data' do
      post "/servers/#{@server.id}/delete"

      expect(Server.count).to eq 0
      expect(response.location).to eq 'http://example.org/'
      expect(response.status).to eq 302
    end

  end
end
