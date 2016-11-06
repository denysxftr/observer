RSpec.describe 'ProjectsController', :vcr do
include ControllerMixin

  let!(:user) { create :user }
  let(:project) { create :project }

  context 'when user signed in' do
    before(:each) do
      post '/sign_in', email: 'example@example.com', password: '12345678'
    end

    describe 'POST /project/new' do
      let(:project) { Project.first }

      it 'returns project page' do
        post '/project/new', name: 'Test test project'
        expect(Project.count).to eq 1
        expect(project.valid?).to eq true
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/project/#{project.id}"
      end
    end

    describe 'GET /projects' do
      let!(:projects) { create_list :project, 5 }

      it 'return page with projects' do
        get '/projects'
        expect(response.errors).to be_empty
        expect(response.status).to eq 200
      end
    end

    describe 'GET /project/id' do
      it 'returns project page' do
        get "/project/#{project.id}"
        expect(response.errors).to be_empty
        expect(response.status).to eq 200
      end
    end

    describe 'POST /project/id' do
      it 'returns project page and updates data' do
        post "/project/#{project.id}", name: 'Try to visit google.com'
        expect(Project.count).to eq 1
        expect(project.reload.valid?).to eq true
        expect(project.reload.name).to eq 'Try to visit google.com'

      end
    end

    describe 'POST /project/id/delete' do
      it 'redirects to main page and deletes projects data' do
        post "/projects/#{project.id}/delete"
        expect(Project.count).to eq 0
        expect(response.location).to eq 'http://example.org/projects'
        expect(response.status).to eq 302
      end
    end
  end

  context "when user didn't sign in" do
    describe 'POST /project/new' do
      let(:project) { Project.first }

      it "redirects to sign in page and doesn't create new project" do
        post '/project/new', name: 'Test test project'
        expect(Project.count).to eq 0
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /projects' do
      let!(:projects) { create_list :project, 5 }

      it 'redirects to sign in page' do
        get '/projects'
        expect(response.errors).to be_empty
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'GET /project/id' do
      it 'redirects to sign in page' do
        get "/project/#{project.id}"
        expect(response.errors).to be_empty
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'POST /project/id' do
      it "redirects to sign in page and doesn't update data" do
        post "/project/#{project.id}", name: 'Try to visit google.com'
        expect(Project.count).to eq 1
        expect(project.reload.name).to_not eq 'Try to visit google.com'
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end

    describe 'POST /project/id/delete' do
      it "redirects to sign in page and doesn't delete project data" do
        post "/projects/#{project.id}/delete"
        expect(Project.count).to eq 1
        expect(response.status).to eq 302
        expect(response.location).to eq "http://example.org/sign_in"
      end
    end
  end
end
