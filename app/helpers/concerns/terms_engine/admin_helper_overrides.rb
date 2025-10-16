# will get loaded but will not get added as a view because it doesn't end with *Helper
module TermsEngine
  module AdminHelperOverrides
    def data_management_admin_resources
      menu = {}
      if authorized?(admin_geo_code_types_path) || authorized?(admin_perspectives_path) || authorized?(admin_views_path) || authorized?(admin_oral_sources_path) || authorized?(admin_note_titles_path)
        menu[GeoCodeType.model_name.human(:count => :many).titleize.s] = admin_geo_code_types_path if authorized? admin_geo_code_types_path
        menu["Create new #{Feature.model_name.human.titleize.s}"] = new_admin_feature_path if authorized? new_admin_feature_path
        menu["Dictionary assistant"] = admin_assistant_path if authorized?(admin_assistant_path)
        menu[FeatureRelationType.model_name.human(:count => :many).titleize.s] = admin_feature_relation_types_path if authorized? admin_feature_relation_types_path
        menu[Perspective.model_name.human(:count => :many).titleize.s] = admin_perspectives_path if authorized? admin_perspectives_path
        menu[View.model_name.human(:count => :many).titleize.s] = admin_views_path if authorized? admin_views_path
        menu[InfoSource.model_name.human(:count => :many).titleize.s] = admin_info_sources_path if authorized? admin_info_sources_path
        menu[OralSource.model_name.human(:count => :many).titleize.s] = admin_oral_sources_path if authorized? admin_oral_sources_path
        menu[NoteTitle.model_name.human(:count => :many).titleize.s] = admin_note_titles_path if authorized? admin_note_titles_path
      end
      return menu
    end
  
    def stacked_parents
      array = [:admin]
      if !parent_object.instance_of?(Feature)
        if parent_object.instance_of?(FeatureNameRelation)
          array << parent_object.child_node
        elsif parent_object.instance_of?(Passage) || parent_object.instance_of?(PassageTranslation) || parent_object.instance_of?(Etymology)
          array << parent_object.context
        elsif parent_object.respond_to?(:feature)
          array << parent_object.feature
        end
      end
      array << parent_object
      array
    end

    def add_breadcrumb_base
      # Notes and Citations are polymorphic. Support breadcrumbs for each of the parent types!
      add_breadcrumb_item feature_link(contextual_feature)
      case parent_type
      when :passage_translation # in terms_engine
        add_breadcrumb_item link_to(PassageTranslation.model_name.human(:count => :many).s, polymorphic_path([:admin, parent_object.feature, parent_object.context], section: 'passage_translations'))
        add_breadcrumb_item link_to(parent_object.content.strip_tags.truncate(25).s,  polymorphic_path([:admin, parent_object]))
      when :passage # in terms_engine
        if parent_object.context.instance_of? Feature
          add_breadcrumb_item link_to(Passage.model_name.human(:count => :many).s, admin_feature_path(parent_object.feature.fid, section: 'passages'))
          add_breadcrumb_item link_to(parent_object.content.strip_tags.truncate(25).s, polymorphic_path([:admin, parent_object.feature, parent_object]))
        else
          add_breadcrumb_item link_to(Passage.model_name.human(:count => :many).s, polymorphic_path([:admin, parent_object.feature, parent_object.context], section: 'passages'))
          add_breadcrumb_item link_to(parent_object.content.strip_tags.truncate(25).s, polymorphic_path([:admin, parent_object.context, parent_object]))
        end
      when :definition # in terms_engine
        add_breadcrumb_item link_to(Definition.model_name.human(:count => :many).s, admin_feature_path(object.feature.fid, section: 'definitions'))
        add_breadcrumb_item link_to( (parent_object.content.blank? ? parent_object.id : parent_object.content.strip_tags.truncate(25).s), admin_feature_definition_path(object.feature, parent_object, section: 'citations'))
      when :description
        add_breadcrumb_item feature_descriptions_link(parent_object.feature)
        add_breadcrumb_item link_to(parent_object.title.strip_tags.truncate(25).titleize.s, admin_feature_description_path(parent_object.feature, parent_object))
      when :feature
      when :feature_name
        add_breadcrumb_item link_to(FeatureName.model_name.human(count: :many).titleize.s, admin_feature_path(parent_object.feature.fid, section: 'names'))
        add_breadcrumb_item link_to(parent_object.name.strip_tags.truncate(25).s, admin_feature_name_path(parent_object))
      when :feature_name_relation
        add_breadcrumb_item feature_names_link(parent_object.child_node.feature.fid)
        add_breadcrumb_item link_to(parent_object.child_node.name, admin_feature_name_path(parent_object.child_node))
        add_breadcrumb_item link_to(ts('relation.this', :count => :many), admin_feature_name_feature_name_relations_path(parent_object.child_node))
        add_breadcrumb_item link_to(parent_object, admin_feature_name_feature_name_relation_path(parent_object.child_node, parent_object))
      when :feature_geo_code
        add_breadcrumb_item link_to(FeatureGeoCode.model_name.human(:count => :many).s, admin_feature_feature_geo_codes_path(parent_object.feature))
        add_breadcrumb_item link_to(parent_object, admin_feature_geo_code_path(parent_object))
      when :feature_relation
        add_breadcrumb_item link_to(ts('relation.this', :count => :many), admin_feature_feature_relations_path(parent_object.child_node))
        add_breadcrumb_item feature_relation_role_label(parent_object.child_node, parent_object, :use_first=>false)
      when :time_unit
        add_breadcrumb_item link_to(ts('date.this', :count => :many), admin_time_units_path)
        add_breadcrumb_item link_to(parent_object.to_s, polymorphic_path([:admin, parent_object]))
      end
    end
  end
end