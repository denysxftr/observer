$(function(){
  if($('#responses_chart').length == 0) {
    return;
  }

  chart = c3.generate({
    bindto: '#responses_chart',
    data: {
      x: 'time',
      xFormat: '%Y-%m-%d %H:%M:%S',
      columns: [],
      types: {
        'response time': 'area'
      }
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
    tooltip: {
      format: {
        value: function (value, ratio, id) {
          return value == -1 ? 'no response or wrong one' : value + 'ms';
        }
      }
    },
    transition: {
      duration: 1
    }
  });

  var extractFailRegions = function(data) {
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
    $.get('/check/' + checkId + '/data', function(data) {
      chart.load({
        columns: [
          ['response time'].concat(_.toArray(data.log)),
          ['time'].concat(_.keysIn(data.log))
        ]
      });
      chart.regions.remove();
      chart.regions.add(extractFailRegions(data.log));
    });
  }

  var checkId = $('#responses_chart').data('id');
  retrieveData();
  setInterval(retrieveData, 10000);
});
