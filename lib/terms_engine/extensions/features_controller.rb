module TermsEngine
  module Extension
    module FeaturesController
      extend ActiveSupport::Concern

      included do
      end
      
      def parse
        @text = params[:text]
        @parsed_text = ShantiIntegration::TranslationTool.translate(@text)['tokens'] || []
        respond_to do |format|
          format.js
        end
      end
      
      def related_list
        @feature = Feature.find(params[:id])
        @feature_relation_type = FeatureRelationType.find(params[:feature_relation_type_id])
        @feature_is_parent = params[:feature_is_parent].to_i
        if @feature_is_parent==0
          @relations = FeatureRelation.where(:feature_relation_type_id => @feature_relation_type.id, :child_node_id => @feature.id, 'cached_feature_names.view_id' => current_view.id).joins(:parent_node => {:cached_feature_names => :feature_name}).order('feature_names.name')
        else
          @relations = FeatureRelation.where(:feature_relation_type_id => @feature_relation_type.id, :parent_node_id => @feature.id, 'cached_feature_names.view_id' => current_view.id).joins(:child_node => {:cached_feature_names => :feature_name}).order('feature_names.name')
        end
        @total_relations_count = @relations.length
        @relations = @relations.paginate(:page => params[:page] || 1, :per_page => 8)
        # render related_list.js.erb
      end

      protected

      def api_format_feature(feature)
        f = {}
        f[:id] = feature.id
        f[:name] = feature.name
        f[:descriptions] = feature.descriptions.collect{|d| {
          :id => d.id,
          :is_primary => d.is_primary,
          :title => d.title,
          :content => d.content,
        }}
        f[:has_shapes] = feature.shapes.empty? ? 0 : 1
        #f[:parents] = feature.parents.collect{|p| api_format_feature(p) }
        f
      end
    end
  end
end
