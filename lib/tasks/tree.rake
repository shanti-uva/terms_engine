require 'terms_engine/tree_processing'

namespace :terms_engine do
  namespace :tree do
    desc "Fix sorting in tree"
    task fix: :environment do
      TermsEngine::TreeProcessing.new.check
    end
  end
end