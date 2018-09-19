$(document).ready(function() {
  $('#recording-selection').on('change', function() {
    change($(this).val());
  });
  
  $('#recording-play-button').click(function(){
    var audio = document.getElementById("recording-player");
    playRecording(audio)
  });
});

function playRecording(audio_element){
  audio_element.pause();
  audio_element.play();
}
function change(sourceUrl) {
  var audio = document.getElementById("recording-player");
  var source = document.getElementById("recording-mp3_src");
  if (sourceUrl) {
    source.src = sourceUrl;
    audio.load();
  }
  playRecording(audio)
}
