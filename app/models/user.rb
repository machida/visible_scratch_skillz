# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[twitter]

  validates :email, presence: true

  has_many :charts, dependent: :destroy

  def no_password
    !!provider
  end

  def name_or_email
    username.presence || email
  end

  class << self
    def from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email || dummy_email(auth)
        user.password = Devise.friendly_token[0, 20]
        user.username = auth.info.name
      end
    end

    private

    def dummy_email(auth)
      "#{auth.uid}-#{auth.provider}@example.com"
    end
  end
end
