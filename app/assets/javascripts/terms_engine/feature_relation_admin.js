$(document).ready(function() {
  $(".selectpicker[data-id='source_definition_id']").addClass("disabled");
  $(".selectpicker[data-id='dest_definition_id']").addClass("disabled");
  $("[name='relation_source']").change(function(e){
    var option = $(this).val();
    if(option === "term"){
      $("#source_definition_id").attr('disabled', true);
      $(".selectpicker[data-id='source_definition_id']").addClass("disabled");
    } else {
      $("#source_definition_id").attr('disabled', false);
      $(".selectpicker[data-id='source_definition_id']").removeClass("disabled");
    }
  });
  $("[name='relation_dest']").change(function(e){
    var option = $(this).val();
    if(option === "term"){
      $("#dest_definition_id").attr('disabled', true);
      $(".selectpicker[data-id='dest_definition_id']").addClass("disabled");
    } else {
      $("#dest_definition_id").attr('disabled', false);
      $(".selectpicker[data-id='dest_definition_id']").removeClass("disabled");
    }
  });
});
