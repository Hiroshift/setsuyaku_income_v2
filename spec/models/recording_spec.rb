require 'rails_helper'

RSpec.describe Recording, type: :model do
  before do
    @recording = FactoryBot.build(:recording)
  end

  describe 'Recordingの保存' do
    context '保存できる場合' do
      it 'amount, recorded_date, userが正しく設定されていれば保存できる' do
        expect(@recording).to be_valid
      end
    end

    context '保存できない場合' do
      it 'amountが空の場合は保存できない' do
        @recording.amount = nil
        expect(@recording).not_to be_valid
        expect(@recording.errors.full_messages).to include("Amount can't be blank")
      end

      it 'recorded_dateが空の場合は保存できない' do
        @recording.recorded_date = nil
        expect(@recording).not_to be_valid
        expect(@recording.errors.full_messages).to include("Recorded date can't be blank")
      end

      it 'userが紐付いていない場合は保存できない' do
        @recording.user = nil
        expect(@recording).not_to be_valid
        expect(@recording.errors.full_messages).to include('User must exist')
      end
    end
  end
  describe '日付変更時のリセット機能' do
    before do
      @user = FactoryBot.create(:user) # ユーザーを作成
    end

    it '日付が変わった場合に今日の収入がリセットされる' do
      FactoryBot.create(:recording, user: @user, amount: 500, recorded_date: Date.yesterday)
      today_income = @user.recordings.where(recorded_date: Date.today).sum(:amount)
      expect(today_income).to eq(0)
    end

    it '同じ日付の場合リセットされない' do
      FactoryBot.create(:recording, user: @user, amount: 500, recorded_date: Date.today)
      today_income = @user.recordings.where(recorded_date: Date.today).sum(:amount)
      expect(today_income).to eq(500)
    end
  end
end
