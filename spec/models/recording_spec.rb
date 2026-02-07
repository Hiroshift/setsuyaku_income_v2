require 'rails_helper'

RSpec.describe Recording, type: :model do
  describe 'バリデーション' do
    context '保存できる場合' do
      it 'amount, recorded_date, userが正しければ保存できる' do
        recording = build(:recording)
        expect(recording).to be_valid
      end

      it 'noteがなくても保存できる' do
        recording = build(:recording, note: nil)
        expect(recording).to be_valid
      end

      it 'noteがあっても保存できる' do
        recording = build(:recording, :with_note)
        expect(recording).to be_valid
      end
    end

    context '保存できない場合' do
      it 'amountが空では保存できない' do
        recording = build(:recording, amount: nil)
        expect(recording).not_to be_valid
      end

      it 'recorded_dateが空では保存できない' do
        recording = build(:recording, recorded_date: nil)
        expect(recording).not_to be_valid
      end

      it 'userが紐付いていなければ保存できない' do
        recording = build(:recording, user: nil)
        expect(recording).not_to be_valid
      end

      it 'amountが負の値では保存できない' do
        recording = build(:recording, amount: -100)
        expect(recording).not_to be_valid
      end
    end
  end

  describe '日付ごとの集計' do
    let(:user) { create(:user) }

    it '今日の記録のみ集計される' do
      create(:recording, user: user, amount: 500, recorded_date: Date.today)
      create(:recording, user: user, amount: 300, recorded_date: Date.yesterday)
      today_income = user.recordings.where(recorded_date: Date.today).sum(:amount)
      expect(today_income).to eq(500)
    end

    it '同じ日に複数記録がある場合は合計される' do
      create(:recording, user: user, amount: 500, recorded_date: Date.today)
      create(:recording, user: user, amount: 300, recorded_date: Date.today)
      today_income = user.recordings.where(recorded_date: Date.today).sum(:amount)
      expect(today_income).to eq(800)
    end
  end

  describe 'noteの保存' do
    let(:user) { create(:user) }

    it 'メモ付きで記録を保存できる' do
      recording = create(:recording, user: user, amount: 500, note: '自炊した')
      expect(recording.reload.note).to eq('自炊した')
    end

    it 'メモなしで記録を保存できる' do
      recording = create(:recording, user: user, amount: 500, note: nil)
      expect(recording.reload.note).to be_nil
    end
  end
end
