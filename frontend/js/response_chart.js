$(function(){
  if($('#responses_chart').length == 0) {
    return;
  }

  chart = c3.generate({
    bindto: '#responses_chart',
    size: {
      height: 200
    },
    data: {
      colors: {
        'good response': '#41C24C',
        'bad response': '#FD7466'
      },
      x: 'time',
      xFormat: '%Y-%m-%d %H:%M:%S',
      columns: [],
      types: {
        'good response': 'area-step',
        'bad response': 'area-step'
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
    transition: {
      duration: 1
    }
  });

  var retrieveData = function() {
    $.get('/check/' + checkId + '/data', function(data) {
      chart.load({
        columns: [
          ['good response'].concat(_.toArray(data.log)),
          ['bad response'].concat(_.toArray(data.fails_log)),
          ['time'].concat(_.keysIn(data.log))
        ]
      });
    });
  }

  var checkId = $('#responses_chart').data('id');
  retrieveData();
  setInterval(retrieveData, 10000);
});
