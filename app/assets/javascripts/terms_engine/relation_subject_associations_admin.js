$(document).ready(function() {
  $("#subject_name").kmapsSimpleTypeahead({
    solr_index: $('#relation_subject_associations_js_data').data('termIndex'),
    domain: $('#relation_subject_associations_js_data').data('domain'),         //[places, subjects, terms]
    autocomplete_field: 'name_autocomplete', //the name of the main field to search in
    match_criterion: 'contains',  //{contains, begins, exactly}
    case_sensitive: false,
    ignore_tree: false,           //This is useful when we want to search in all trees
  }).bind('typeahead:select',
        function (ev, sel) {
        //The return value includes the domain, i.e. subjects-653
        $("#subject_id").val(sel.doc.id.replace($('#relation_subject_associations_js_data').data('domain')+'-',''));
        }
      );
   var selectAncestorSolrUtils = kmapsSolrUtils.init({
    termIndex: $('#relation_subject_associations_js_data').data('termIndex'),
    assetIndex: $('#relation_subject_associations_js_data').data('assetIndex'),
    featureId: $('#relation_subject_associations_js_data').data('featureId'),
    domain: $('#relation_subject_associations_js_data').data('domain'),
    perspective: $('#relation_subject_associations_js_data').data('perspective'),
    tree: $('#relation_subject_associations_js_data').data('tree'), //places
    featuresPath: $('#relation_subject_associations_js_data').data('featuresPath'),
  });

  $("#js-expand-subject-tree").click(function(event) {
    event.preventDefault();
    if($("#js-expand-subject-tree").text().includes('hide')){
      $("#js-expand-subject-tree").text("Or click here to view subject hierarchy");
    } else {
      $("#js-expand-subject-tree").text("Or click here to hide subject hierarchy");
    }
    $("#subject_tree_container").toggle();
  });

  //Code for relation_type branch verification
  var relation_types = $("#relation_subject_associations_js_data").data('relationTypes').reduce((acc, relation_type) => {
    acc[relation_type.id] = relation_type.branch_id;
    return acc;
  }, {});

  var subject_assocation_handler = function(e) {
    var relation_type = $("#feature_relation_feature_relation_type_id").val().replace('_','');
    if(relation_types[relation_type]) {
      var relation_type_branch_id = relation_types[relation_type];
      $("#branch_id").val(relation_type_branch_id);
      $("#subject_name").kmapsSimpleTypeahead('updateAdditionalFilters',["ancestor_id_gen_path:"+relation_type_branch_id+"/* OR ancestor_id_gen_path:**/"+relation_type_branch_id+"/*"]);

      if ($("#subject_tree_container")) {
        $("#subject_tree_container").remove();
        $("#subject_container").append('<div id="subject_tree_container"></div>');
        $("#js-expand-subject-tree").text("Or click here to hide subject hierarchy");

      }
      $("#subject_tree_container").kmapsRelationsTree({
        featureId: $('#relation_subject_associations_js_data').data('domain')+"-"+relation_type_branch_id,
        featuresPath: $('#relation_subject_associations_js_data').data('featuresPath'),
        termIndex: $('#relation_subject_associations_js_data').data('termIndex'),
        assetIndex: $('#relation_subject_associations_js_data').data('assetIndex'),
        perspective: $('#relation_subject_associations_js_data').data('perspective'),
        tree: $('#relation_subject_associations_js_data').data('tree'), //places
        domain: $('#relation_subject_associations_js_data').data('domain'), //places
        extraFields: ["header"],
        descendants: false,
        hideAncestors: true,
        descendantsFullDetail: false,
        displayPopup: false,
        solrUtils: selectAncestorSolrUtils,
        nodeMarkerPredicates: [{operation: 'markAll', mark: 'customActionNode'}], //A predicate is: {field:, value:, operation: 'eq', mark: 'nonInteractive'}
      });
      $("#subject_tree_container").on("fancytreeactivate", function(event, data){
        $("#subject_name").val(data.node.title.replace(/(<([^>]+)>)/ig,""));
        $("#subject_id").val(data.node.key.replace($('#relation_subject_associations_js_data').data('domain')+'-',''));
      });
      $("#subject_container").show();
    } else {
      $("#subject_id").val("");
      $("#subject_container").hide();
    }
  };
  subject_assocation_handler();
  $("#feature_relation_feature_relation_type_id").change(subject_assocation_handler);
});
