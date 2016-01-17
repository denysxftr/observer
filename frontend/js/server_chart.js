$(function(){
  if($('#server_chart').length == 0) {
    return;
  }

  chart = c3.generate({
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

  var extractFailRagions = function(data) {
    var regions = [];
    var positive = true;
    var start = null;
    _.forEach(data, function(value, key) {
      if(value == -1 && positive) {
        positive = false;
        start = key;
      }

      if(value > -1 && !positive) {
        positive = true
        regions.push({ axis: 'x', start: start, end: key })
      }

      if(value > -1) {
        positive = true;
      }
    })

    if(!positive) {
      regions.push({ axis: 'x', start: start, end:  _.last(_.keysIn(data)) })
    }
    return regions;
  }

  var retrieveData = function() {
    $.get('/server/' + serverId + '/data', function(data) {
      chart.load({
        columns: [
          ['CPU'].concat(data.cpu),
          ['time'].concat(data.time)
        ]
      });
    });
  }

  var serverId = $('#server_chart').data('id');
  retrieveData();
  setInterval(retrieveData, 10000);
});
