class Recording < ApplicationRecord
  belongs_to :feature
  has_one_attached :audio_file

  validates :feature, presence: true
  validate :audio_validation
  validates :dialect_id, presence: true

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
