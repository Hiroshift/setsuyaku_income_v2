require 'rails_helper'

RSpec.describe 'History', type: :request do
  let(:user) { create(:user, hourly_rate: 1200) }

  describe 'GET /history (未ログイン)' do
    it 'ログインページにリダイレクトされる' do
      get history_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe 'GET /history (ログイン済み)' do
    before { sign_in user }

    it '履歴ページが表示される' do
      get history_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('これまでの節約収入')
    end

    context '記録がある場合' do
      before do
        create(:recording, user: user, amount: 1000, recorded_date: Date.today, note: '自炊した')
        create(:recording, user: user, amount: 500, recorded_date: Date.yesterday)
      end

      it '累計金額が表示される' do
        get history_path
        expect(response.body).to include('¥1,500')
      end

      it '労働時間換算が表示される' do
        get history_path
        expect(response.body).to include('ぶんの労働')
      end

      it '個別の記録が表示される' do
        get history_path
        expect(response.body).to include('¥1,000')
        expect(response.body).to include('¥500')
      end

      it 'メモが表示される' do
        get history_path
        expect(response.body).to include('自炊した')
      end
    end

    context '記録がない場合' do
      it 'エラーなく表示される' do
        get history_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('¥0')
      end
    end
  end

  describe 'DELETE /recordings/:id' do
    before { sign_in user }

    context '自分の記録を削除' do
      it '記録が削除される' do
        recording = create(:recording, user: user, amount: 500)
        expect {
          delete recording_path(recording)
        }.to change(Recording, :count).by(-1)
      end

      it 'フラッシュメッセージが表示される' do
        recording = create(:recording, user: user, amount: 500)
        delete recording_path(recording)
        expect(flash[:notice]).to include('¥500の記録を取り消しました')
      end

      it '履歴ページにリダイレクトされる' do
        recording = create(:recording, user: user, amount: 500)
        delete recording_path(recording)
        expect(response).to redirect_to(history_path)
      end
    end

    context '他のユーザーの記録' do
      it '削除できない' do
        other_user = create(:user)
        recording = create(:recording, user: other_user, amount: 500)
        delete recording_path(recording)
        expect(flash[:alert]).to include('見つかりませんでした')
        expect(Recording.count).to eq(1)
      end
    end

    context '存在しないID' do
      it 'エラーメッセージが表示される' do
        delete recording_path(id: 99999)
        expect(flash[:alert]).to include('見つかりませんでした')
      end
    end
  end
end
