# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  validates :nickname, presence: true
  validates :gender, presence: true, inclusion: { in: %w[male female other] }
  validates :relationship_status, presence: true, inclusion: { in: %w[dating married] }
end
