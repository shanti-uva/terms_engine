$(document).ready(function() {
  var branch_id = $('#etymology_type_associations_js_data').data('branchId').replace($('#etymology_type_associations_js_data').data('domain')+'-','')
  $("#subject_name").kmapsSimpleTypeahead({
    solr_index: $('#etymology_type_associations_js_data').data('termIndex'),
    domain: $('#etymology_type_associations_js_data').data('domain'),         //[places, subjects, terms]
    autocomplete_field: 'name_autocomplete', //the name of the main field to search in
    additional_filters: ["ancestor_id_gen_path:"+branch_id+"/* OR ancestor_id_gen_path:*/"+branch_id+"/*"],
    match_criterion: 'contains',  //{contains, begins, exactly}
    case_sensitive: false,
    ignore_tree: false,           //This is useful when we want to search in all trees
  }).bind('typeahead:select',
        function (ev, sel) {
        //The return value includes the domain, i.e. subjects-653
        $("#subject_id").val(sel.doc.id.replace($('#etymology_type_associations_js_data').data('domain')+'-',''));
        }
      );
   var selectAncestorSolrUtils = kmapsSolrUtils.init({
    termIndex: $('#etymology_type_associations_js_data').data('termIndex'),
    assetIndex: $('#etymology_type_associations_js_data').data('assetIndex'),
    featureId: $('#etymology_type_associations_js_data').data('featureId'),
    domain: $('#etymology_type_associations_js_data').data('domain'),
    perspective: $('#etymology_type_associations_js_data').data('perspective'),
    tree: $('#etymology_type_associations_js_data').data('tree'), //places
    featuresPath: $('#etymology_type_associations_js_data').data('featuresPath'),
  });

    if($('#etymology_type_associations_js_data').data('branchId') != '') {
    $("#subject_tree_container").kmapsRelationsTree({
      featureId: $('#etymology_type_associations_js_data').data('branchId'),
      featuresPath: $('#etymology_type_associations_js_data').data('featuresPath'),
      termIndex: $('#etymology_type_associations_js_data').data('termIndex'),
      assetIndex: $('#etymology_type_associations_js_data').data('assetIndex'),
      perspective: $('#etymology_type_associations_js_data').data('perspective'),
      tree: $('#etymology_type_associations_js_data').data('tree'), //places
      domain: $('#etymology_type_associations_js_data').data('domain'), //places
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
      $("#subject_id").val(data.node.key.replace($('#etymology_type_associations_js_data').data('domain')+'-',''));
    });
  }

  $("#subject_tree_container").hide();

  $("#js-expand-subject-tree").click(function(event) {
    event.preventDefault();
    if($("#js-expand-subject-tree").text().includes('hide')){
      $("#js-expand-subject-tree").text("Or click here to view subject hierarchy");
    } else {
      $("#js-expand-subject-tree").text("Or click here to hide subject hierarchy");
    }
    $("#subject_tree_container").toggle();
  });
});
