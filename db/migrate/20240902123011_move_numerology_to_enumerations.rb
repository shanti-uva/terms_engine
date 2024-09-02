class MoveNumerologyToEnumerations < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.transaction do
      Definition.where("numerology IS NOT NULL").each do |d|
        e = Enumeration.new(:feature_id => d.feature_id, :value => d.numerology)
        e.save
      end
    end
  end
end
