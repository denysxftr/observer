$(function(){
  if($('#server_chart_cpu').length == 0) {
    return;
  }

  var chart_cpu = c3.generate({
    bindto: '#server_chart_cpu',
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


  var chart_ram = c3.generate({
    bindto: '#server_chart_ram',
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
    $.get('/server/' + serverId + '/data', function(data) {
      chart_cpu.load({
        columns: [
          ['CPU'].concat(data.cpu),
          ['time'].concat(data.time)
        ]
      });

      chart_ram.load({
        columns: [
          ['MEM'].concat(data.ram),
          ['time'].concat(data.time)
        ]
      });
    });
  }

  var serverId = $('#server_chart_cpu').data('id');
  retrieveData();
  setInterval(retrieveData, 10000);
});
