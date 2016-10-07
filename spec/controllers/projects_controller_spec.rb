RSpec.describe 'ProjectsController', :vcr do
include ControllerMixin

  let!(:user) { create :user }

  before(:each) do
    post '/sign_in', email: 'example@mail.com', password: 'passw_1234'
  end

  describe 'POST /project/new' do
    let(:project) { Project.first }

    it 'returns project page' do
      post '/project/new', name: 'Test test project'
      expect(Project.count).to eq 1
      expect(project.valid?).to eq true
      expect(response.status).to eq 302
      expect(response.location).to eq "http://example.org/projects"
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
    let!(:project) { create :project }

    it 'returns project page' do
      get "/project/#{project.id}"

      expect(response.errors).to be_empty
      expect(response.status).to eq 200
    end
  end

  describe 'POST /project/id' do
    let!(:project) { create :project }

    it 'returns project page and updates data' do
      post "/project/#{project.id}", name: 'Try to visit google.com'

      expect(Project.count).to eq 1
      expect(project.reload.valid?).to eq true
      expect(project.reload.name).to eq 'Try to visit google.com'

    end
  end

  describe 'POST /project/id/delete' do
    let!(:project) { create :project }

    it 'redirects to main page and deletes projects data' do
      post "/projects/#{project.id}/delete"

      expect(Project.count).to eq 0
      expect(response.location).to eq 'http://example.org/projects'
      expect(response.status).to eq 302
    end

  end
end
