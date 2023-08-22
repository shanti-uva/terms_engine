module TermsEngine
  module Extension
    module PerspectiveModel
      extend ActiveSupport::Concern

      included do
      end

      module ClassMethods

        def get_by_language_code(code)
          perspective_code = Rails.cache.fetch("perspective/language/#{code}", :expires_in => 1.day) do
            case code
            when 'eng' then 'eng.alpha'
            when 'bod' then 'tib.alpha'
            else nil
            end
          end
          perspective_code.nil? ? nil : Perspective.get_by_code(perspective_code)
        end
      end
    end
  end
end
