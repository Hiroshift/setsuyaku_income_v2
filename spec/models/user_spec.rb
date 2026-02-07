require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end

  describe 'ユーザー新規登録' do
    context '新規登録できるとき' do
      it '全ての値が正しく入力されていれば登録できる' do
        expect(@user).to be_valid
      end
    end

    context '新規登録できないとき' do
      it 'nicknameが空では登録できない' do
        @user.nickname = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("ニックネームを入力してください")
      end

      it 'emailが空では登録できない' do
        @user.email = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("メールアドレスを入力してください")
      end

      it 'passwordが空では登録できない' do
        @user.password = ''
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワードを入力してください")
      end

      it 'passwordとpassword_confirmationが不一致では登録できない' do
        @user.password = 'abc123'
        @user.password_confirmation = 'abc124'
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワード（確認）がパスワードと一致しません")
      end

      it 'nicknameが51文字以上では登録できない' do
        @user.nickname = 'a' * 51
        @user.valid?
        expect(@user.errors.full_messages).to include('ニックネームは50文字以内にしてください')
      end

      it '重複したemailが存在する場合は登録できない' do
        @user.save
        another_user = FactoryBot.build(:user)
        another_user.email = @user.email
        another_user.valid?
        expect(another_user.errors.full_messages).to include('メールアドレスはすでに登録されています')
      end

      it 'emailは@を含まないと登録できない' do
        @user.email = 'testmail'
        @user.valid?
        expect(@user.errors.full_messages).to include('メールアドレスの形式が正しくありません')
      end

      it 'passwordが5文字以下では登録できない' do
        @user.password = '00000'
        @user.password_confirmation = '00000'
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは6文字以上にしてください')
      end

      it 'passwordが129文字以上では登録できない' do
        @user.password = 'a' * 129
        @user.password_confirmation = @user.password
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは128文字以内にしてください')
      end

      it 'hourly_rateが空では登録できない' do
        @user.hourly_rate = nil
        @user.valid?
        expect(@user.errors.full_messages).to include("時給を入力してください")
      end

      it 'hourly_rateが0では登録できない（時給0円ではアプリが機能しない）' do
        @user.hourly_rate = 0
        @user.valid?
        expect(@user.errors.full_messages).to include('時給は1円以上で入力してください')
      end

      it 'hourly_rateが負の値では登録できない' do
        @user.hourly_rate = -1
        @user.valid?
        expect(@user.errors.full_messages).to include('時給は1円以上で入力してください')
      end
    end

    context 'パスワードの更新時' do
      it 'パスワードが空欄でも更新できる' do
        @user.save
        updated = @user.update_without_password(nickname: '新しいニックネーム')
        expect(updated).to be true
      end

      it '新しいパスワードが6文字以上で半角英数字混合であれば更新できる' do
        @user.save
        @user.password = 'new123'
        @user.password_confirmation = 'new123'
        expect(@user.update(password: @user.password, password_confirmation: @user.password_confirmation)).to be true
      end

      it '新しいパスワードが6文字未満では更新できない' do
        @user.save
        @user.password = '12345'
        @user.password_confirmation = '12345'
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは6文字以上にしてください')
      end

      it '新しいパスワードが半角英数字混合でない場合は更新できない' do
        @user.save
        @user.password = 'abcdef'
        @user.password_confirmation = 'abcdef'
        @user.valid?
        expect(@user.errors.full_messages).to include('パスワードは英字と数字の両方を含めてください')
      end

      it 'パスワード確認が一致しない場合は更新できない' do
        @user.save
        @user.password = 'new123'
        @user.password_confirmation = 'new124'
        @user.valid?
        expect(@user.errors.full_messages).to include("パスワード（確認）がパスワードと一致しません")
      end
    end
  end
end

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.create(:user)
  end

  describe 'ユーザーの削除' do
    context 'アカウント削除時' do
      it 'ユーザーがデータベースから削除されること' do
        expect { @user.destroy }.to change { User.count }.by(-1)
      end

      it '関連するrecordingsも削除されること' do
        FactoryBot.create(:recording, user: @user)
        expect { @user.destroy }.to change { Recording.count }.by(-1)
      end
    end
  end
end
