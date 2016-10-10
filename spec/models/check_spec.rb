RSpec.describe Check do
  describe 'if all values is valid' do
    let!(:check) { create :check }
    it 'should not be errors' do
      expect(check.errors).to be_empty
    end
  end

  describe 'if fields are invalid' do
    describe 'when name is blank' do
      let(:check) { build :check, name: '' }
      it 'throws an error' do
        expect(check.valid?).to eq false
        expect(check.errors[:name]).to include("can't be blank")
      end
    end

    describe 'if retries has value < 0' do
      let(:check) { build :check, retries: -100 }
      it 'throws an error greater' do
        expect(check.valid?).to eq false
        expect(check.errors[:retries]).to include("must be greater than 0")
      end
    end

    describe 'if retries is not number' do
      let(:check) { build :check, retries: 'by' }
      it 'throws an error not number' do
        expect(check.valid?).to eq false
        expect(check.errors[:retries]).to include("is not a number")
      end
    end

  end
end
