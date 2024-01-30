  $(document).ready(function() {

    const section = window.location.href.split('=')[1];

    switch(section){
     
      case('captions'):
        handleFeatureAccordion('collapseFour');
        break;
      case('collections'):
        handleFeatureAccordion('collapseTwo');
        break;
      case('definitions'):
        handleFeatureAccordion('collapseTen');
        break;
      case('descriptions'):
        handleFeatureAccordion('#collapseNine');
        break;
      case('etymologies'):
        handleFeatureAccordion('collapseThirteen');
        break;
      case('geocodes'):
        handleFeatureAccordion('collapseSeven');
        break;
      case('illustrations'):
        handleFeatureAccordion('collapseSix');
        break;
      case('names'):
        handleFeatureAccordion('collapseThree');
        break;
      case('passages'):
        handleFeatureAccordion('collapsePassages');
        break;
      case('recordings'):
        handleFeatureAccordion('collapseEleven');
        break;
      case('relations'):
        handleFeatureAccordion('collapseEight');
        break;
      case('subjectAssociations'):
        handleFeatureAccordion('collapseTwelve');
        break;
      case('summaries'):
        handleFeatureAccordion('collapseFive');
        break;
      default:
        console.log("default");
        break;
    }
    
    function handleFeatureAccordion(el){
      // General Information is shown by default so hide it
      $('#collapseOne').collapse('hide');
      $('#' + el).collapse('toggle');
      setTimeout(1000);
      document.getElementById(el).scrollIntoView({behavior: "smooth" });
    }
});

