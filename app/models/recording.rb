# == Schema Information
#
# Table name: recordings
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  dialect_id :integer
#  feature_id :bigint
#
# Indexes
#
#  index_recordings_on_feature_id  (feature_id)
#
# Foreign Keys
#
#  fk_rails_...  (feature_id => features.id)
#

class Recording < ApplicationRecord
  validates :feature, presence: true
  validate :audio_validation
  validates :dialect_id, presence: true
  
  belongs_to :feature, touch: true
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
