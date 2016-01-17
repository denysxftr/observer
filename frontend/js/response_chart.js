$(function(){
  chart = c3.generate({
    bindto: '#chart',
    data: {
      x: 'time',
      xFormat: '%Y-%m-%d %H:%M:%S',
      columns: columns
    },
    regions: regions,
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
          return value == -1 ? 'no response' : value + 'ms';
        }
      }
    },
    transition: {
      duration: 1
    }
  });

  setInterval(function(){
    $.get('/ping/5', function(data) {
      chart.load({
        columns: [
          ['response time'].concat(data.timeouts_log.values),
          ['time'].concat(data.timeouts_log.keys)
        ]
      });
      chart.regions.remove();
      chart.regions.add(data.incidents_regions);
    });
  }, 60000);
});
