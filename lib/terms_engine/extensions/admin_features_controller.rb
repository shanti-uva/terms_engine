module TermsEngine
  module Extension
    module AdminFeaturesController
      extend ActiveSupport::Concern

      included do
        # We want to remove the default action created in KmapsEngine
        new_action.wants.html {}
      end

      def create_english_term
        # TODO: Create english_cleanup to remove leading and trailing spaces
        current_entry = params[:term_name].chomp
        @current_term = Feature.search_english_term(current_entry)
        if @current_term.nil?
          eng_alpha = Perspective.get_by_code('eng.alpha')
          relation_type = FeatureRelationType.get_by_code('is.beginning.of')
          parent = EnglishTermsService.new.trunk_for(current_entry)
          subject_id = params[:feature][:subject_term_associations][:subject_id]
          @current_term = EnglishTermsService.add_term(subject_id, current_entry)
          @object = @current_term
          FeatureRelation.create!(child_node: @current_term, parent_node: parent, perspective: eng_alpha, feature_relation_type: relation_type, skip_update: true)
          ts = EnglishTermsService.new(parent)
          ts.reposition
          parent.queued_index
          @name = nil
        else
          @object = Feature.new
          object.errors.add :base, t('feature.errors.term_exists')
          @name = current_entry
        end
        respond_to do |format|
          format.html { @name.nil? ? redirect_to(admin_feature_url(object.fid)) : render('admin/features/new') }
        end
      end

      def create_tibetan_term
        current_entry = params[:term_name].tibetan_cleanup
        @current_term = Feature.search_bod_expression(current_entry)
        if @current_term.nil?
          tib_alpha = Perspective.get_by_code('tib.alpha')
          relation_type = FeatureRelationType.get_by_code('heads')
          parent = TibetanTermsService.recursive_trunk_for(current_entry)
          if parent.ancestors_by_perspective(tib_alpha).count != 2
            @object = Feature.new
            object.errors.add :base, "There is a problem for term: #{current_entry} with calculated parent: #{parent.pid} in herarchy. Skipping term creation."
            @name = current_entry
          else
            wylie = TibetanTermsService.get_wylie(current_entry)
            phonetic = TibetanTermsService.get_phonetic(current_entry)
            @current_term = TibetanTermsService.add_term(Feature::BOD_EXPRESSION_SUBJECT_ID, current_entry, wylie, phonetic)
            @object = @current_term
            FeatureRelation.create!(child_node: @current_term, parent_node: parent, perspective: tib_alpha, feature_relation_type: relation_type, skip_update: true)
            ts = TibetanTermsService.new(parent)
            ts.reposition
            parent.queued_index
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
