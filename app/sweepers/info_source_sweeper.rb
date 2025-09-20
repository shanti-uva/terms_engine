class InfoSourceSweeper < ActionController::Caching::Sweeper
  include InterfaceUtils::SweeperExtensions
  include Rails.application.routes.url_helpers
  include ActionController::Caching::Pages
  
  observe InfoSource
  FORMATS = ['xml', 'json']
  
  def after_save(record)
    expire_cache(record)
  end
  
  def after_touch(record)
    expire_cache(record)
  end
  
  def after_destroy(record)
    expire_cache(record)
  end
  
  def expire_cache(perspective)
    options = {:only_path => true}
    FORMATS.each do |format|
      options[:format] = format
      expire_full_path_page admin_info_sources_url(options)
    end
  end
end