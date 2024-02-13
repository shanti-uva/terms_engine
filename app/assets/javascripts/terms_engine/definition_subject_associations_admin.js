$(document).ready(function() {
  $("#branch_name").kmapsSimpleTypeahead({
    solr_index: $('#definition_subject_association_js_data').data('termIndex'),
    domain: $('#definition_subject_association_js_data').data('domain'),         //[places, subjects, terms]
    autocomplete_field: 'name_autocomplete', //the name of the main field to search in
    match_criterion: 'contains',  //{contains, begins, exactly}
    case_sensitive: false,
    ignore_tree: false,           //This is useful when we want to search in all trees
  }).bind('typeahead:select',
        function (ev, sel) {
          //The return value includes the domain, i.e. subjects-653
          $("#branch_id").val(sel.doc.id.replace($('#definition_subject_association_js_data').data('domain')+'-',''));
          $("#subject_name").kmapsSimpleTypeahead('updateAdditionalFilters',["ancestor_id_gen_path:"+$('#branch_id').val()+"/* OR ancestor_id_gen_path:**/"+$('#branch_id').val()+"/*"]);
      });
  $("#subject_name").kmapsSimpleTypeahead({
    solr_index: $('#definition_subject_association_js_data').data('termIndex'),
    domain: $('#definition_subject_association_js_data').data('domain'),         //[places, subjects, terms]
    autocomplete_field: 'name_autocomplete', //the name of the main field to search in
    additional_filters: ["ancestor_id_gen_path:"+$('#branch_id').val()+"/* OR ancestor_id_gen_path:*/"+$('#branch_id').val()+"/*"],
    match_criterion: 'contains',  //{contains, begins, exactly}
    case_sensitive: false,
    ignore_tree: false,           //This is useful when we want to search in all trees
  }).bind('typeahead:select',
        function (ev, sel) {
        //The return value includes the domain, i.e. subjects-653
        $("#subject_id").val(sel.doc.id.replace($('#definition_subject_association_js_data').data('domain')+'-',''));
        }
      );

   var selectAncestorSolrUtils = kmapsSolrUtils.init({
    termIndex: $('#definition_subject_association_js_data').data('termIndex'),
    assetIndex: $('#definition_subject_association_js_data').data('assetIndex'),
    featureId: $('#definition_subject_association_js_data').data('featureId'),
    domain: $('#definition_subject_association_js_data').data('domain'),
    perspective: $('#definition_subject_association_js_data').data('perspective'),
    tree: $('#definition_subject_association_js_data').data('tree'), //places
    featuresPath: $('#definition_subject_association_js_data').data('featuresPath'),
  });
  $("#branch_tree_container").kmapsRelationsTree({
    featureId: $('#definition_subject_association_js_data').data('featureId'),
    featuresPath: $('#definition_subject_association_js_data').data('featuresPath'),
    termIndex: $('#definition_subject_association_js_data').data('termIndex'),
    assetIndex: $('#definition_subject_association_js_data').data('assetIndex'),
    perspective: $('#definition_subject_association_js_data').data('perspective'),
    tree: $('#definition_subject_association_js_data').data('tree'), //places
    domain: $('#definition_subject_association_js_data').data('domain'), //places
    extraFields: ["header"],
    descendants: false,
    descendantsFullDetail: false,
    displayPopup: false,
    solrUtils: selectAncestorSolrUtils,
    nodeMarkerPredicates: [{operation: 'markAll', mark: 'customActionNode'}], //A predicate is: {field:, value:, operation: 'eq', mark: 'nonInteractive'}
  });
  $("#branch_tree_container").on("fancytreeactivate", function(event, data){
    $("#branch_name").val(data.node.title.replace(/(<([^>]+)>)/ig,""));
    $("#branch_id").val(data.node.key.replace($('#definition_subject_association_js_data').data('domain')+'-',''));
    $("#subject_name").kmapsSimpleTypeahead('updateAdditionalFilters',["ancestor_id_gen_path:"+$('#branch_id').val()+"/* OR ancestor_id_gen_path:**/"+$('#branch_id').val()+"/*"]);

    if ($("#subject_tree_container")) {
      $("#subject_tree_container").remove();
      $("#subject_container").append('<div id="subject_tree_container"></div>');
      $("#js-expand-subject-tree").text("Or click here to hide subject hierarchy");

    }
    $("#subject_tree_container").kmapsRelationsTree({
      featureId: $('#definition_subject_association_js_data').data('domain')+"-"+$('#branch_id').val(),
      featuresPath: $('#definition_subject_association_js_data').data('featuresPath'),
      termIndex: $('#definition_subject_association_js_data').data('termIndex'),
      assetIndex: $('#definition_subject_association_js_data').data('assetIndex'),
      perspective: $('#definition_subject_association_js_data').data('perspective'),
      tree: $('#definition_subject_association_js_data').data('tree'), //places
      domain: $('#definition_subject_association_js_data').data('domain'), //places
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
      $("#subject_id").val(data.node.key.replace($('#definition_subject_association_js_data').data('domain')+'-',''));
    });
  });
  if($("#branch_id").val() != '') {
    $("#subject_tree_container").kmapsRelationsTree({
      featureId: $('#definition_subject_association_js_data').data('domain')+"-"+$('#branch_id').val(),
      featuresPath: $('#definition_subject_association_js_data').data('featuresPath'),
      termIndex: $('#definition_subject_association_js_data').data('termIndex'),
      assetIndex: $('#definition_subject_association_js_data').data('assetIndex'),
      perspective: $('#definition_subject_association_js_data').data('perspective'),
      tree: $('#definition_subject_association_js_data').data('tree'), //places
      domain: $('#definition_subject_association_js_data').data('domain'), //places
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
      $("#subject_id").val(data.node.key.replace($('#definition_subject_association_js_data').data('domain')+'-',''));
    });
  }

  $("#subject_tree_container").hide();
  $("#branch_tree_container").hide();
  $("#js-expand-branch-tree").click(function(event) {
    event.preventDefault();
    if($("#js-expand-branch-tree").text().includes('hide')){
      $("#js-expand-branch-tree").text("Or click here to view branch hierarchy");
    } else {
      $("#js-expand-branch-tree").text("Or click here to hide branch hierarchy");
    }
    $("#branch_tree_container").toggle();
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

  // just show this by default now
  $("#branch_tree_container").toggle();
});
