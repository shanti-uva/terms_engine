# Methods added to this helper will be available to all templates in the application.
module TermsEngineHelper
  def custom_secondary_tabs_list
    # The :index values are necessary for this hash's elements to be sorted properly
    {
      :place => {:index => 1, :title => 'Overview', :shanticon => 'overview'},
      :descriptions => {:index => 2, :title => 'Essays', :shanticon => 'texts'},
      :related => {:index => 3, :title => Feature.model_name.human(count: :many).titleize, :shanticon => 'terms'}
    }
  end
  
  def kmaps_url(feature)
    ''
    #feature_places_path(feature.fid)
  end
end
