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
    var logOfTimes = _.keysIn(data.log);
    var log = _.toArray(data.log);
    var logOfFails = _.toArray(data.fails_log);
    var logOfIssues = _.toArray(data.issues_log);
    var amount = log.length;
    var max = _.max(log) || _.max(logOfFails);
    for(var i = 0; i < amount; i++){
      parentContainer.append('<div class= "chart-bar" data-id='+ i +'></div>');
      if(log[i]){
        $('div[data-id='+ i +']').width(width/amount+'%')
                                  .height((height-1)/max*log[i])
                                  .addClass('hint--bottom hint--small')
                                  .attr('aria-label', logOfTimes[i]);
      }
      else if(logOfFails[i]){
        $('div[data-id='+ i +']').width(width/amount+'%')
                                  .height((height-1)/max*logOfFails[i])
                                  .addClass('fail hint--bottom hint--small hint--warning')
                                  .attr('aria-label',  logOfTimes[i] + ' - ' + logOfIssues[i]);
      }
      else{
        $('div[data-id='+ i +']').width(width/amount+'%')
                                  .height((height-1)/max*logOfFails[i])
                                  .addClass('network-fail hint--bottom hint--small hint--error')
                                  .attr('aria-label',  logOfTimes[i] + ' - ' + logOfIssues[i]);
      }
      if(i % legendScale == 0){
        $('div[data-id='+ i +']').append('<span>' + logOfTimes[i].split(' ')[1] + '</span>');
      }
    }
  }
  function obtainData(){
    $.get('/check/' + checkId + '/data', function(data) {
      drawDiagram(data);
    })
  }
  obtainData();
  setInterval(obtainData, 50000);
});
