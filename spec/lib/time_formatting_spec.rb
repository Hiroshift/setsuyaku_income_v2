require 'rails_helper'
require 'ostruct'

# TimeFormattingをテストするためのヘルパークラス
class TimeFormattingTestHelper
  include TimeFormatting

  attr_accessor :current_user

  def initialize(hourly_rate:)
    @current_user = OpenStruct.new(hourly_rate: hourly_rate)
  end
end

RSpec.describe TimeFormatting do
  let(:helper) { TimeFormattingTestHelper.new(hourly_rate: 1200) }

  describe '#calculate_minutes' do
    it '時給1200円で1200円の節約は60分' do
      expect(helper.send(:calculate_minutes, 1200)).to eq(60)
    end

    it '時給1200円で600円の節約は30分' do
      expect(helper.send(:calculate_minutes, 600)).to eq(30)
    end

    it '時給1200円で100円の節約は5分' do
      expect(helper.send(:calculate_minutes, 100)).to eq(5)
    end

    it '0円の節約は0分' do
      expect(helper.send(:calculate_minutes, 0)).to eq(0)
    end

    context '時給が0の場合' do
      let(:helper) { TimeFormattingTestHelper.new(hourly_rate: 0) }

      it '0を返す' do
        expect(helper.send(:calculate_minutes, 1000)).to eq(0)
      end
    end
  end

  describe '#format_time' do
    it '30分は「30分」と表示' do
      expect(helper.send(:format_time, 30)).to eq('30分')
    end

    it '60分は「1時間」と表示' do
      expect(helper.send(:format_time, 60)).to eq('1時間')
    end

    it '90分は「1時間30分」と表示' do
      expect(helper.send(:format_time, 90)).to eq('1時間30分')
    end

    it '120分は「2時間」と表示' do
      expect(helper.send(:format_time, 120)).to eq('2時間')
    end

    it '0分は「0分」と表示' do
      expect(helper.send(:format_time, 0)).to eq('0分')
    end
  end

  describe '#format_life_time' do
    it '30分は「30分」' do
      expect(helper.send(:format_life_time, 30)).to eq('30分')
    end

    it '90分は「1時間30分」' do
      expect(helper.send(:format_life_time, 90)).to eq('1時間30分')
    end

    it '1440分（24時間）は「1日」' do
      expect(helper.send(:format_life_time, 1440)).to eq('1日')
    end

    it '1500分は「1日1時間」（分は省略）' do
      expect(helper.send(:format_life_time, 1500)).to eq('1日1時間')
    end

    it '2880分は「2日」' do
      expect(helper.send(:format_life_time, 2880)).to eq('2日')
    end

    it '3000分は「2日2時間」' do
      expect(helper.send(:format_life_time, 3000)).to eq('2日2時間')
    end

    it '0分は「0分」' do
      expect(helper.send(:format_life_time, 0)).to eq('0分')
    end
  end
end
