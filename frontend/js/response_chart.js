$(function () {
  if ($('#checks_chart').length == 0) {
    return;
  }

  var checkId = $('#checks_chart').data('id');

  function drawDiagram(data) {
    var parentContainer = $('#checks_chart');
    parentContainer.html('');
    var width = 100;
    var legendScale = 20;
    var height = parentContainer.height();
    var log = data.log;
    var amount = log.length;
    var maxOfTimeouts = _.maxBy(log, item =>  { return item.timeout; } ).timeout;
    log.forEach((item, index) => {
      var bar = $('<div class="chart-bar" data-id=' + index + '></div>')
        .width(width / amount + '%')
        .height((height - 1) / maxOfTimeouts * item.timeout)
        .addClass('hint--bottom hint--small');
      if (item.timeout && !item.issues) {
        bar.attr('aria-label', item.time + ' - ' + item.timeout);
      } else if (item.timeout && item.issues) {
        bar.addClass('fail hint--warning')
          .attr('aria-label', item.time + ' - ' + item.timeout + ' - ' + item.issues);
      } else {
        bar.height(height - 1)
          .addClass('network-fail hint--error')
          .attr('aria-label', item.time + ' - ' + item.issues);
      }

      if (index % legendScale == 0) {
        bar.append('<span>' + item.time.split(' ')[1] + '</span>');
      }

      parentContainer.append(bar);
    });
  }

  function obtainData() {
    $.get('/check/' + checkId + '/data', function (data) {
      drawDiagram(data);
    })
  }

  obtainData();
  setInterval(obtainData, 50000);
});
