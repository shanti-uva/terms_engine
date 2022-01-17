class TermsResource < ActiveResource::Base
  #cached_resource
  
  case InterfaceUtils::Server.environment
  when InterfaceUtils::Server::DEVELOPMENT
    self.site = "http://dev-terms.kmaps.virginia.edu/"
  when InterfaceUtils::Server::STAGING
    self.site = "http://staging-terms.kmaps.virginia.edu/"
  when InterfaceUtils::Server::PRODUCTION
    self.site = "http://terms.kmaps.virginia.edu/"
  when InterfaceUtils::Server::LOCAL
    self.site = "http://localhost/terms/"
  else
    self.site = "http://terms.kmaps.virginia.edu/"
  end

  self.timeout = 100
  self.format = :xml
end