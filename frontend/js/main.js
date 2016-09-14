$(function(){
  $('.js-select-tags').select2({
    tags: true,
    tokenSeparators: [',', ' '],
    width: '300px'
  })

  $(".piety.donut").peity("donut", {
    fill: ['#666', '#ccc'],
    radius: 15
  })
});
