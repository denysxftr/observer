$(function(){
  if($('#checks_chart').length == 0) {
    return;
  }

  var checkId = $('#checks_chart').data('id');

  function drawDiagram(data){
    var parentContainer = $('#checks_chart');
    parentContainer.html('');
    var width = 100;
    var legendScale = 20;
    var height = parentContainer.height();
    var log = data.log;
    var amount = log.length;
    var maxOfTimeouts = _.maxBy(log, function(item){ return item.timeout; }).timeout;
    log.forEach(function(item, index){
      parentContainer.append('<div class= "chart-bar" data-id='+ index +'></div>');
      if(item.timeout && !item.issues){
        $('div[data-id='+ index +']').width(width/amount+'%')
                                  .height((height-1)/maxOfTimeouts*item.timeout)
                                  .addClass('hint--bottom hint--small')
                                  .attr('aria-label', item.time + ' - ' + item.timeout);
      }
      else if(item.timeout && item.issues){
        $('div[data-id='+ index +']').width(width/amount+'%')
                                  .height((height-1)/maxOfTimeouts*item.timeout)
                                  .addClass('fail hint--bottom hint--small hint--warning')
                                  .attr('aria-label',  item.time + ' - ' + item.timeout + ' - ' + item.issues);
      }
      else{
        $('div[data-id='+ index +']').width(width/amount+'%')
                                  .height(height-1)
                                  .addClass('network-fail hint--bottom hint--small hint--error')
                                  .attr('aria-label',  item.time + ' - ' + item.issues);
      }
      if(index % legendScale == 0){
        $('div[data-id='+ index +']').append('<span>' + item.time.split(' ')[1] + '</span>');
      }
    });
  }

  function obtainData(){
    $.get('/check/' + checkId + '/data', function(data) {
      drawDiagram(data);
    })
  }
  
  obtainData();
  setInterval(obtainData, 50000);
});
