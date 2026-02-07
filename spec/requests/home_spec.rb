require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET / (未ログイン)' do
    it 'LPが表示される' do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('節約は、収入だ。')
    end

    it 'ログインフォームへのリンクがある' do
      get root_path
      expect(response.body).to include('ログイン')
    end
  end

  describe 'GET / (ログイン済み)' do
    let(:user) { create(:user, hourly_rate: 1200) }

    before { sign_in user }

    it 'ダッシュボードが表示される' do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('いくら節約しましたか？')
      expect(response.body).to include('収入に変える')
    end

    it '今日の節約収入が表示される' do
      create(:recording, user: user, amount: 500, recorded_date: Date.today)
      get root_path
      expect(response.body).to include('¥500')
      expect(response.body).to include('今日の節約収入')
    end

    it '累計が表示される' do
      create(:recording, user: user, amount: 1000, recorded_date: Date.today)
      create(:recording, user: user, amount: 2000, recorded_date: Date.yesterday)
      get root_path
      expect(response.body).to include('¥3,000')
      expect(response.body).to include('これまでの節約収入')
    end

    it '日付選択チップが表示される' do
      get root_path
      expect(response.body).to include('今日')
      expect(response.body).to include('昨日')
      expect(response.body).to include('一昨日')
    end

    it 'メモ欄が表示される' do
      get root_path
      expect(response.body).to include('何を節約した？')
    end

    context '連続記録がある場合' do
      it '連続日数が表示される' do
        create(:recording, user: user, amount: 500, recorded_date: Date.today)
        create(:recording, user: user, amount: 300, recorded_date: Date.yesterday)
        get root_path
        expect(response.body).to include('日連続')
      end
    end

    context '昨日の記録がない場合' do
      it 'ナッジが表示される' do
        create(:recording, user: user, amount: 500, recorded_date: 2.days.ago)
        get root_path
        expect(response.body).to include('昨日の記録がありません')
      end
    end
  end

  describe 'POST /new_income' do
    let(:user) { create(:user, hourly_rate: 1200) }

    before { sign_in user }

    context '正常な記録' do
      it '記録が保存される' do
        expect {
          post new_income_path, params: { amount: 500, recorded_date: Date.today.to_s, note: '自炊した' }
        }.to change(Recording, :count).by(1)
      end

      it 'フラッシュメッセージに金額と労働時間が含まれる' do
        post new_income_path, params: { amount: 1200, recorded_date: Date.today.to_s }
        expect(flash[:notice]).to include('¥1,200の節約収入')
        expect(flash[:notice]).to include('1時間ぶんの労働')
      end

      it 'フラッシュメッセージにメモが含まれる' do
        post new_income_path, params: { amount: 500, recorded_date: Date.today.to_s, note: '自炊した' }
        expect(flash[:notice]).to include('自炊した')
      end

      it 'ホームにリダイレクトされる' do
        post new_income_path, params: { amount: 500, recorded_date: Date.today.to_s }
        expect(response).to redirect_to(root_path)
      end
    end

    context '日付指定' do
      it '昨日の日付で記録できる' do
        post new_income_path, params: { amount: 500, recorded_date: Date.yesterday.to_s }
        expect(Recording.last.recorded_date).to eq(Date.yesterday)
      end

      it '一昨日の日付で記録できる' do
        post new_income_path, params: { amount: 500, recorded_date: 2.days.ago.to_date.to_s }
        expect(Recording.last.recorded_date).to eq(2.days.ago.to_date)
      end

      it '未来の日付は今日に置き換えられる' do
        post new_income_path, params: { amount: 500, recorded_date: (Date.today + 1).to_s }
        expect(Recording.last.recorded_date).to eq(Date.today)
      end

      it '8日以上前の日付は今日に置き換えられる' do
        post new_income_path, params: { amount: 500, recorded_date: 8.days.ago.to_date.to_s }
        expect(Recording.last.recorded_date).to eq(Date.today)
      end
    end

    context '不正な入力' do
      it '金額0ではエラーになる' do
        post new_income_path, params: { amount: 0, recorded_date: Date.today.to_s }
        expect(flash[:alert]).to include('正しく入力')
        expect(Recording.count).to eq(0)
      end

      it '負の金額ではエラーになる' do
        post new_income_path, params: { amount: -100, recorded_date: Date.today.to_s }
        expect(flash[:alert]).to include('正しく入力')
      end
    end

    context 'メモ' do
      it 'メモなしでも記録できる' do
        post new_income_path, params: { amount: 500, recorded_date: Date.today.to_s }
        expect(Recording.last.note).to be_nil
      end

      it '空白のみのメモはnilとして保存される' do
        post new_income_path, params: { amount: 500, recorded_date: Date.today.to_s, note: '   ' }
        expect(Recording.last.note).to be_nil
      end
    end
  end

  describe 'GET /welcome' do
    let(:user) { create(:user, hourly_rate: 1200, nickname: 'テスト') }

    before { sign_in user }

    it 'ウェルカム画面が表示される' do
      get welcome_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('ようこそ、テストさん')
    end

    it '時給が表示される' do
      get welcome_path
      expect(response.body).to include('¥1,200')
    end

    it '換算例が表示される' do
      get welcome_path
      expect(response.body).to include('ぶんの労働')
    end
  end
end
