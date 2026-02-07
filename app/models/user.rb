class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :recordings, dependent: :destroy

  def premium?
    premium
  end

  validates :nickname, presence: true, length: { maximum: 50 }
  validates :hourly_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # パスワードのバリデーションを条件付きに設定
  validates :password, format: {
    with: /\A(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]+\z/,
    message: 'is invalid. Include both letters and numbers'
  }, allow_nil: true
end
