# == Schema Information
#
# Table name: info_sources
#
#  id             :bigint           not null, primary key
#  agent          :string
#  code           :string           not null
#  date_published :date
#  processed      :boolean          default(FALSE), not null
#  title          :string
#  created_at     :datetime
#  updated_at     :datetime
#
# Indexes
#
#  info_sources_code_key  (code) UNIQUE
#

class InfoSource < ActiveRecord::Base
  has_many :citations
  
  # Validation
  validates_presence_of :code
  
  def self.search(filter_value)
    self.where(build_like_conditions(%W(info_sources.code info_sources.title info_sources.agent), filter_value))
  end
  
  def self.get_by_code(code)
    if code.blank?
      info_source = nil
    else
      @cache_by_codes ||= {}
      info_source = @cache_by_codes[code]
      if info_source.nil?
        info_source = self.find_by(code: code)
        @cache_by_codes[code] = info_source if !info_source.nil?
      end
    end
    raise "Info source #{code} not found." if info_source.nil? && !code.blank?
    info_source
  end
  
  def bibliographic_reference
    return self.title
  end
end
