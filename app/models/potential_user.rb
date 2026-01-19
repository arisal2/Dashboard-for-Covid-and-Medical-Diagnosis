# frozen_string_literal: true

# Model for Potential User
class PotentialUser < ApplicationRecord
  def self.import(file)
    PotentialUser.destroy_all

    CSV.foreach(file.path, headers: true) do |row|
      PotentialUser.create! row.to_h
    end
  end

  def self.validate_email
    PotentialUser.all.filter_map do |user|
      next unless Truemail.valid?(user.email)

      user.email
    end
  end
end
