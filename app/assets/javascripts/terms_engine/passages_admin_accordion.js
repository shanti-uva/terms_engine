$(document).ready(function() {

    if( $('.logged-in.page-terms #passageShow #accordion').length ) { // only run this on the admin passage accordion in terms_engine

      const section = window.location.href.split('=')[1];
      if( section == null || section === undefined ) { return; } // exit if we didn't get a section

      switch(section) {
        // TODO add notes section
        case('citations'):
          handleFeatureAccordion('collapseCitations');
          break;
        case('passage_translations'):
          handleFeatureAccordion('collapsePassageTranslations');
          break;
        default:
          //handleFeatureAccordion('collapseOne');
          break;
      }
      
      function handleFeatureAccordion(el){
        // General Information is shown by default so hide it
        $('#collapseOne').collapse('hide');
        $('#' + el).collapse('toggle');
        setTimeout(1000);
        //TODO there is something else running on the page that prevents this from working consistently.
        //It has to do with the sidebar list of terms.
        document.getElementById(el).scrollIntoView({behavior: "smooth" });
      }
    }
});
