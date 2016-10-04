$(function(){
  if($('#checks_chart').length == 0) {
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

  var checkId = $('#checks_chart').data('id');
  // retrieveData();
  // setInterval(retrieveData, 10000);

  function drawDiagram(data){
    $("#ckecks_chart").html("");
    var width = $("#checks_chart").width();
    var height = $("#checks_chart").height();
    var log = _.toArray(data.log)
    var amount = log.length;
    var max = Math.max.apply(Math, log);
    var parentContainer = $('#checks_chart');
    for(var i = 0; i < amount; i++){
      parentContainer.append("<div class= 'chart-bar' data-id="+ i +"></div>");
      $("div[data-id="+ i +"]").width(width/amount).height(100/max*log[i]);
    }
  }
  function obtainData(){
    $.get('/check/' + checkId + '/data', function(data) {
      drawDiagram(data);
    })
  }
  obtainData();
  //$(window).resize( obtainData());
});
