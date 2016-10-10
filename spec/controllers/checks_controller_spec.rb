RSpec.describe 'ChecksController', :vcr do
include ControllerMixin

  let!(:user) { create :user }
  let(:check) { create :check }

  context 'if user signed in' do
    before(:each) do
      post '/sign_in', email: 'example@mail.com', password: 'passw_1234'
    end

    describe 'POST /check/new' do
      let(:check) { Check.first }

      it 'returns check page' do
        post '/check/new', name: 'Try to visit google.com', url: 'http://google.com', expected_status: 302, project_id: '', retries: 1
        expect(Check.count).to eq 1
        expect(check.valid?).to eq true
        expect(check.url).to eq 'http://google.com'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/check/#{check.id}"
      end
    end

    describe 'GET /checks' do
      let!(:checks) { create_list :check, 5 }

      it 'return page with checks' do
        get '/checks'
        expect(response.errors).to be_empty
        expect(response.status).to eq 200
      end
    end

    describe 'GET /check/id' do
        it 'returns check page' do
        get "/check/#{check.id}"

        expect(response.errors).to be_empty
        expect(response.status).to eq 200
      end
    end

    describe 'GET /check/id/data' do
      context 'if check has results' do
        let(:result) { create :result }

        it 'returns json with data' do
          check.results << result
          get "/check/#{check.id}/data"
          expect(response.errors).to be_empty
          expect(response.content_type).to eq 'application/json'
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['log']).to_not be_empty
        end
      end

      context 'if check has no results' do
        it 'returns an empty json' do
          get "/check/#{check.id}/data"
          expect(response.errors).to be_empty
          expect(response.content_type).to eq 'application/json'
          expect(response.status).to eq 200
          json = JSON.parse(response.body)
          expect(json['log']).to be_empty
        end
      end
    end

    describe 'POST /check/id' do
      it 'returns check page and updates data' do
        post "/check/#{check.id}", name: 'Try to visit google.com', url: 'http://google.com', expected_status: 302, project_id: '', retries: 1
        expect(Check.count).to eq 1
        expect(check.reload.valid?).to eq true
        expect(check.reload.name).to eq 'Try to visit google.com'

      end
    end

    describe 'POST /check/id/delete' do
      it 'redirects to main page and deletes check data' do
        post "/check/#{check.id}/delete"
        expect(Check.count).to eq 0
        expect(response.location).to eq 'http://example.org/'
        expect(response.status).to eq 302
      end
    end
  end

  context "if user didn't sign in" do
    describe 'POST /check/new' do
      let(:check_new) { Check.first }
      it "redirects to sign in page and doesn't create new check" do
        post '/check/new', name: 'Try to visit google.com', url: 'http://google.com', expected_status: 302, project_id: '', retries: 1
        expect(Check.count).to eq 0
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /checks' do
      let!(:checks) { create_list :check, 5 }

      it 'redirects to sign in page' do
        get '/checks'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /check/id' do
      it 'redirects to sign in page' do
        get "/check/#{check.id}"
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /check/id/data' do
      it 'redirects to sign in page' do
        get "/check/#{check.id}/data"
        expect(response.errors).to be_empty
        expect(response.content_type).to_not eq 'application/json'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'POST /check/id' do
      it "returns check page and doesn't update data" do
        post "/check/#{check.id}", name: 'Try to visit google.com', url: 'http://google.com', expected_status: 302, project_id: '', retries: 1
        expect(Check.count).to eq 1
        expect(check.reload.name).to_not eq 'Try to visit google.com'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'POST /check/id/delete' do
      it "redirects to main page and doesn't delete check data" do
        post "/check/#{check.id}/delete"
        expect(Check.count).to eq 1
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end
  end
end
