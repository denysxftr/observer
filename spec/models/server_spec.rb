RSpec.describe Server do
  describe 'if all values is valid' do
    let!(:server) { create :server }
    it 'should not be errors' do
      expect(server.errors).to be_empty
    end
  end

  describe 'if fields are invalid' do
    describe 'when name is blank' do
      let(:server) { build :server, name: '' }
      it 'throws an error' do
        server.valid?
        expect(server.errors[:name]).to include("can't be blank")
      end
    end
  end
end
