$(function(){
  $('select').chosen({
    width: '200px'
  });

  $(".piety.donut").peity("donut", {
    fill: ['#666', '#ccc'],
    radius: 15
  })
});
