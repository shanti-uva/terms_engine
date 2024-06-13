module ExtendedAdminHelper
  def extended_data_management_admin_resources
    menu = {}
    if authorized?(admin_geo_code_types_path) || authorized?(admin_perspectives_path) || authorized?(admin_views_path) || authorized?(admin_oral_sources_path) || authorized?(admin_note_titles_path)
      menu[GeoCodeType.model_name.human(:count => :many).titleize.s] = admin_geo_code_types_path if authorized? admin_geo_code_types_path
      menu["Create new #{Feature.model_name.human.titleize.s}"] = new_admin_feature_path if authorized? new_admin_feature_path
      menu[FeatureRelationType.model_name.human(:count => :many).titleize.s] = admin_feature_relation_types_path if authorized? admin_feature_relation_types_path
      menu[Perspective.model_name.human(:count => :many).titleize.s] = admin_perspectives_path if authorized? admin_perspectives_path
      menu[View.model_name.human(:count => :many).titleize.s] = admin_views_path if authorized? admin_views_path
      menu[InfoSource.model_name.human(:count => :many).titleize.s] = admin_info_sources_path if authorized? admin_info_sources_path
      menu[OralSource.model_name.human(:count => :many).titleize.s] = admin_oral_sources_path if authorized? admin_oral_sources_path
      menu[NoteTitle.model_name.human(:count => :many).titleize.s] = admin_note_titles_path if authorized? admin_note_titles_path
    end
    return menu
  end
  
  def extended_stacked_parents
    array = [:admin]
    if !parent_object.instance_of?(Feature)
      if parent_object.instance_of?(FeatureNameRelation)
        array << parent_object.child_node
      elsif parent_object.instance_of?(Passage) || parent_object.instance_of?(PassageTranslation)
        array << parent_object.context
      elsif parent_object.respond_to?(:feature)
        array << parent_object.feature
      end
    end
    array << parent_object
    array
  end
end
