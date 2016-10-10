$(function(){
  if($('#server_chart').length === 0) {
    return;
  }

  var chart = c3.generate({
    bindto: '#server_chart',
    size: {
      height: 400
    },
    data: {
      x: 'time',
      xFormat: '%Y-%m-%d %H:%M:%S',
      columns: [],
      type: 'area-step'
    },
    regions: [],
    point: {
      show: false
    },
    axis: {
      x: {
        type: 'timeseries',
        tick: {
          count: 20,
          format: '%H:%M:%S %d/%m'
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
      duration: 0
    }
  });

  var retrieveData = function() {
    $('.panel .loading').show()
    var timezone = -(new Date()).getTimezoneOffset()/60
    var path = ''
    if (isMonth) {
      path = '/server/' + serverId + '/log_data?from=' + window.fromTime + '&to=' + window.toTime + '&timezone=' + timezone;
    } else {
      path = '/server/' + serverId + '/data?from=' + window.fromTime + '&to=' + window.toTime + '&timezone=' + timezone;
    }

    $.get(path, function(data) {
      chart.load({
        columns: [
          ['CPU'].concat(data.cpu),
          ['MEM'].concat(data.ram),
          ['SWAP'].concat(data.swap),
          ['time'].concat(data.time)
        ]
      });
      $('.panel .loading').hide()
    });
  }

  var serverId = $('#server_chart').data('id');
  var time = $('#server_chart').data('time');
  var isMonth = !!$('#server_chart').data('month');
  var slider = document.getElementById('time_slider');
  var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  if (isMonth) {
    fromTime = 7
    toTime = 0
    noUiSlider.create(slider,
      {
        start: [0, 7],
        direction: 'rtl',
        connect: true,
        range: {
          'min': 0,
          'max': 30
        },
        step: 1,
        pips: {
          mode: 'steps',
          format: {
            to: function(v){
              var d = new Date()
              d.setDate(d.getDate() - v);
              return [d.getDate(), monthNames[d.getMonth()]].join(' ');
            }
          },
          filter: function(v) { return (v % 2); },
          density: 3
        }
      });
  } else {
    fromTime = 6
    toTime = 0
    noUiSlider.create(slider,
      {
        start: [0, 6],
        connect: true,
        direction: 'rtl',
        range: {
          'min': 0,
          'max': 24
        },
        step: 1,
        pips: {
          mode: 'steps',
          format: {
            to: function(v){
              var d = new Date()
              d.setHours(d.getHours() - v);
              return [d.getHours(), d.getMinutes()].join(':');
            }
          },
          filter: function(v) { return (v % 2) + 2; },
          density: 1
        }
      });
  }
  slider.noUiSlider.on('change', function(){
    var values = document.getElementById('time_slider').noUiSlider.get()
    window.fromTime = parseInt(values[1], 10);
    window.toTime = parseInt(values[0], 10);

    retrieveData();
  });

  retrieveData();
});
