require 'terms_engine/tree_processing'

namespace :terms_engine do
  namespace :tree do
    desc "Fix sorting in tree"
    task fix: :environment do
      TermsEngine::TreeProcessing.new.check
    end
    
    desc "Generate newar tree"
    task generate_newar: :environment do
      TermsEngine::TreeProcessing.new.run_newar_tree_flattening_fixed
    end
    
  end
end