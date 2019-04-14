# == Schema Information
#
# Table name: recordings
#
#  id         :bigint(8)        not null, primary key
#  feature_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  dialect_id :integer
#

class Recording < ApplicationRecord
  validates :feature, presence: true
  validate :audio_validation
  validates :dialect_id, presence: true
  
  belongs_to :feature
  has_one_attached :audio_file
  has_many :imports, :as => 'item', :dependent => :destroy
  
  def dialect
    SubjectsIntegration::Feature.flare_search(self.dialect_id)
  end

  private
  def audio_validation
    logger.debug "Audio Validation called"
    if audio_file.attached?
      logger.debug "The audio file has been attached"
    end
    return true
  end
end
