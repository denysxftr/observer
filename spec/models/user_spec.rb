RSpec.describe Server do
  describe 'if all values is valid' do
    let!(:user) { create :user }
    it 'should not be errors' do
      expect(user.errors).to be_empty
    end
  end

  describe 'if fields are invalid' do
    describe 'when name is blank' do
      let(:user) { build :user, name: '' }
      it 'throws an error' do
        user.valid?
        expect(user.errors[:name]).to include("can't be blank")
      end
    end

    describe 'when email is blank' do
      let(:user) { build :user, email: '' }
      it 'throws an error' do
        user.valid?
        expect(user.errors[:email]).to include("can't be blank")
      end
    end

    describe 'when password is blank' do
      let(:user) { build :user, password_hash: '' }
      it 'throws an error' do
        user.valid?
        expect(user.errors[:password_hash]).to include("can't be blank")
      end
    end
  end
end
