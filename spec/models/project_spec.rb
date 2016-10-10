RSpec.describe Project do
  describe 'if all values is valid' do
    let!(:project) { create :project }
    it 'should not be errors' do
      expect(project.errors).to be_empty
    end
  end

  describe 'if fields are invalid' do
    describe 'when name is blank' do
      let(:project) { build :project, name: '' }
      it 'throws an error' do
        project.valid?
        expect(project.errors[:name]).to include("can't be blank")
      end
    end
  end
end
