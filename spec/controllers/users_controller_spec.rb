RSpec.describe 'UsersController', :vcr do
include ControllerMixin
  context 'if main user is admin' do
    let!(:user_admin) { create :user_admin }

    before(:each) do
      post '/sign_in', email: 'example_admin@mail.com', password: 'passw_1234'
    end

    describe 'POST /users' do
      let(:user) { User.where(email: 'test').first }

      it 'saves user and redirects to users page' do
        post '/users', name: 'Test user created', password: 'test', email: 'test'
        expect(User.count).to eq 2
        expect(user.valid?).to eq true
        expect(user.name).to eq 'Test user created'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/users"
      end
    end

    describe 'POST /user/id' do
      let!(:user) { create :user }

      it 'returns users page and updates data' do
        post "/user/#{user.id}", name: 'Test user updated'
        expect(User.count).to eq 2
        expect(user.reload.valid?).to eq true
        expect(user.reload.name).to eq 'Test user updated'
      end
    end

    describe 'POST /user/id/delete' do
      let!(:user) { create :user }

      it 'redirects to user page and deletes user data' do
        post "/user/#{user.id}/delete"
        expect(User.count).to eq 1
        expect(response.location).to eq 'http://example.org/users'
        expect(response.status).to eq 302
      end
    end
  end

  context 'if main user is not admin' do
    let!(:user_trying) { create :user }

    before(:each) do
      post '/sign_in', email: 'example@mail.com', password: 'passw_1234'
    end

    describe 'POST /users' do
      it "don't saves user and redirects to users page" do
        post '/users', name: 'Test user created', password: 'test', email: 'test'
        expect(User.count).to eq 1
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/"
      end
    end

    describe 'POST /user/id' do
      let!(:user) { create :user, email: 'example@qwe.com' }

      it "doesn't update data" do
        post "/user/#{user.id}", name: 'Test user updated'
        expect(user.reload.name).to_not eq 'Test user updated'
        expect(User.count).to eq 2
      end
    end

    describe 'POST /user/id/delete' do
      let!(:user) { create :user }

      it "redirects to main page and doesn't delete user data" do
        post "/user/#{user.id}/delete"
        expect(User.count).to eq 2
        expect(response.location).to eq 'http://example.org/'
        expect(response.status).to eq 302
      end
    end
  end
end
