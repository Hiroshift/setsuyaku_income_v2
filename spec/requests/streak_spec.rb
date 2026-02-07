require 'rails_helper'

RSpec.describe '連続記録（streak）', type: :request do
  let(:user) { create(:user, hourly_rate: 1200) }

  before { sign_in user }

  context '今日だけ記録がある場合' do
    it 'streakは1' do
      create(:recording, user: user, recorded_date: Date.today)
      get root_path
      expect(response.body).to include('1')
      expect(response.body).to include('日連続')
    end
  end

  context '今日と昨日に記録がある場合' do
    it 'streakは2' do
      create(:recording, user: user, recorded_date: Date.today)
      create(:recording, user: user, recorded_date: Date.yesterday)
      get root_path
      expect(response.body).to include('2')
      expect(response.body).to include('日連続')
    end
  end

  context '3日連続で記録がある場合' do
    it 'streakは3' do
      create(:recording, user: user, recorded_date: Date.today)
      create(:recording, user: user, recorded_date: Date.yesterday)
      create(:recording, user: user, recorded_date: 2.days.ago.to_date)
      get root_path
      expect(response.body).to include('3')
      expect(response.body).to include('日連続')
    end
  end

  context '今日記録がなく昨日だけある場合' do
    it 'streakは1（昨日から数える）' do
      create(:recording, user: user, recorded_date: Date.yesterday)
      get root_path
      expect(response.body).to include('1')
      expect(response.body).to include('日連続')
    end
  end

  context '記録が全くない場合' do
    it 'streakは表示されない' do
      get root_path
      expect(response.body).not_to include('日連続')
    end
  end
end
