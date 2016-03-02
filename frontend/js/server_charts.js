$(function(){
  if($('#server_chart').length == 0) {
    return;
  }

  var chart = c3.generate({
    bindto: '#server_chart',
    data: {
      x: 'time',
      xFormat: '%Y-%m-%d %H:%M:%S',
      columns: []
    },
    regions: [],
    point: {
      show: false
    },
    axis: {
      x: {
        type: 'timeseries',
        tick: {
          count: 10,
          format: '%H:%M:%S'
        }
      },
      y: {
        min: 0,
        max: 90,
        padding: { top: 50, bottom: 0 }
      }
    },
    legend: {
      show: false
    },
    transition: {
      duration: 1
    }
  });

  var retrieveData = function() {
    $.get('/server/' + serverId + '/data?time=' + time, function(data) {
      chart.load({
        columns: [
          ['CPU'].concat(data.cpu),
          ['MEM'].concat(data.ram),
          ['SWAP'].concat(data.swap),
          ['time'].concat(data.time)
        ]
      });
    });
  }

  var serverId = $('#server_chart').data('id');
  var time = $('#server_chart').data('time');
  retrieveData();
  setInterval(retrieveData, 10000);
});
