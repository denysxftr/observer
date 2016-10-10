RSpec.describe 'SessionController', :vcr do
include ControllerMixin

  let!(:user) { create :user }

  describe 'POST \sign_in' do
    context 'if user exists' do
      it 'shows main page' do
        post '/sign_in', email: 'example@mail.com', password: 'passw_1234'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/"
      end
    end

    context 'if there are no users with such credentials' do
      it "don't show main page" do
        post '/sign_in', email: 'example1@mail.com', password: 'passw_1234'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end
  end

  describe 'GET \sign_out' do

    it 'redirects to sign in page' do
      post '/sign_in', email: 'example@mail.com', password: 'passw_1234'
      get '/sign_out'
      expect(response.location).to eq "http://example.org/sign_in"
    end
  end
end
