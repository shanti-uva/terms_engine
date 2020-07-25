$(document).ready(function() {
  $("#recording-play-button").click(function(e){
    e.preventDefault();
    $("#current_recording")[0].play();
  });

  $("#dialect_name").kmapsSimpleTypeahead({
    solr_index: $('#subject_association_js_data').data('termIndex'),
    domain: $('#subject_association_js_data').data('domain'),         //[places, subjects, terms]
    autocomplete_field: 'name_autocomplete', //the name of the main field to search in
    additional_filters: $('#subject_association_js_data').data('additionalFilters'),
    match_criterion: 'contains',  //{contains, begins, exactly}
    case_sensitive: false,
    ignore_tree: false,           //This is useful when we want to search in all trees
  }).bind('typeahead:select',
    function (ev, sel) {
      //The return value includes the domain, i.e. subjects-653
      $("#dialect_id").val(sel.doc.id.replace($('#subject_association_js_data').data('domain')+'-',''));
    }
  );
  var selectAncestorSolrUtils = kmapsSolrUtils.init({
    termIndex: $('#recording_dialect_js_data').data('termIndex'),
    assetIndex: $('#recording_dialect_js_data').data('assetIndex'),
    featureId: $('#recording_dialect_js_data').data('featureId'),
    domain: $('#recording_dialect_js_data').data('domain'),
    perspective: $('#recording_dialect_js_data').data('perspective'),
    view: $('#recording_dialect_js_data').data('view'),
    tree: $('#recording_dialect_js_data').data('tree'), //places
    featuresPath: $('#recording_dialect_js_data').data('featuresPath'),
  });
  $("#relation_tree_container").kmapsRelationsTree({
    featureId: $('#recording_dialect_js_data').data('featureId'),
    featuresPath: $('#recording_dialect_js_data').data('featuresPath'),
    termIndex: $('#recording_dialect_js_data').data('termIndex'),
    assetIndex: $('#recording_dialect_js_data').data('assetIndex'),
    perspective: $('#recording_dialect_js_data').data('perspective'),
    view: $('#recording_dialect_js_data').data('view'),
    tree: $('#recording_dialect_js_data').data('tree'), //places
    domain: $('#recording_dialect_js_data').data('domain'), //places
    extraFields: ["header"],
    descendants: false,
    directAncestors: true,
    hideAncestors: true,
    descendantsFullDetail: false,
    displayPopup: false,
    solrUtils: selectAncestorSolrUtils,
    nodeMarkerPredicates: [{operation: 'markAll', mark: 'customActionNode'}], //A predicate is: {field:, value:, operation: 'eq', mark: 'nonInteractive'}
  });
  $("#relation_tree_container").on("fancytreeactivate", function(event, data){
    $("#dialect_name").val(data.node.title.replace(/(<([^>]+)>)/ig,""));
    $("#dialect_id").val(data.node.key.replace($('#subject_association_js_data').data('domain')+'-',''));
  });

  $("#relation_tree_container").hide();
  $("#js-expand-dialect-tree").click(function(event) {
    event.preventDefault();
    if($("#js-expand-dialect-tree").text().includes('hide')){
      $("#js-expand-dialect-tree").text("Or click here to view dialect hierarchy");
    } else {
      $("#js-expand-dialect-tree").text("Or click here to hide dialect hierarchy");
    }
    $("#relation_tree_container").toggle();
  });
});
