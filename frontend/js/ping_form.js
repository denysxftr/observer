$(function(){
  $('.js-ping-type-select').change(function(event){
    var isPing = $(event.target).val() == '1';
    if(isPing) {
      $('.js-http-method-input').hide();
    } else {
      $('.js-http-method-input').show();
    };
  });
});
