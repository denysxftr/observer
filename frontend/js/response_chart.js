$(function(){
  c3.generate({
    bindto: '#chart',
    data: {
        x: 'time',
        xFormat: '%Y-%m-%d %H:%M:%S',
        columns: columns
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
        min: 5
      }
    }
  });
});
