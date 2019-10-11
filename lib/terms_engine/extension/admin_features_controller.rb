module TermsEngine
  module Extension
    module AdminFeaturesController
      extend ActiveSupport::Concern

      included do
        new_action.wants.html {}
      end

      def create_tibetan_term
        current_entry = params[:term_name].tibetan_cleanup
        @current_term = Feature.search_expression(current_entry)
        if @current_term.nil?
          tib_alpha = Perspective.get_by_code('tib.alpha')
          relation_type = FeatureRelationType.get_by_code('is.beginning.of')
          parent = TermsService.recursive_trunk_for(current_entry)
          if parent.ancestors_by_perspective(tib_alpha).count != 2
            @object = Feature.new
            object.errors.add :base, "There is a problem for term: #{current_entry} with calculated parent: #{parent.pid} in herarchy. Skipping term creation."
            @name = current_entry
          else
            wylie = TermsService.get_wylie(current_entry)
            phonetic = TermsService.get_phonetic(current_entry)
            @current_term = TermsService.add_term(Feature::EXPRESSION_SUBJECT_ID, current_entry, wylie, phonetic)
            @object = @current_term
            FeatureRelation.create!(child_node: @current_term, parent_node: parent, perspective: tib_alpha, feature_relation_type: relation_type)
            ts = TermsService.new(parent)
            ts.reposition
            @name = nil
          end
        else
          @object = Feature.new
          object.errors.add :base, t('feature.errors.term_exists')
          @name = current_entry
        end
        respond_to do |format|
          format.html { @name.nil? ? redirect_to(admin_feature_url(object.fid)) : render('admin/features/new') }
        end
      end
    end
  end
end
