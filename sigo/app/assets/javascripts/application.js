// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery_nested_form
//= require turbolinks

$(document).ready(function(){
  $("#left-panel ul li a").click(function(){
    $.company_global_id= $(this).attr("company");
  });

  if($.validator != 'undefined'){
    $.validator.addMethod(
      "greaterThan",
      function(value, element, params) {
          var target = $(params).val();
          var isValueNumeric = !isNaN(parseFloat(value)) && isFinite(value);
          var isTargetNumeric = !isNaN(parseFloat(target)) && isFinite(target);
          if (isValueNumeric && isTargetNumeric) {
              return Number(value) >= Number(target);
          }

          if (!/Invalid|NaN/.test(new Date(value))) {
              return new Date(value) >= new Date(target);
          }

          return false;
      },
      'Must be greater than {0}.');
  }
});

function load_graphic(div_id){
  $('#'+div_id).highcharts({
    title: {
        text: 'Monthly Average Temperature',
        x: -20 //center
    },
    subtitle: {
        text: 'Source: WorldClimate.com',
        x: -20
    },
    xAxis: {
        categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    },
    yAxis: {
        title: {
            text: 'Temperature (°C)'
        },
        plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
        }]
    },
    tooltip: {
        valueSuffix: '°C'
    },
    legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle',
        borderWidth: 0
    },
    series: [{
        name: 'Tokyo',
        data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]
    }, {
        name: 'New York',
        data: [-0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]
    }, {
        name: 'Berlin',
        data: [-0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]
    }, {
        name: 'London',
        data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
    }]
  });
}

function load_lineal_graphic_for_general_report(div_id, title, subtitle, serie1, serie2, serie3){
  $('#'+div_id).highcharts({
    chart: {
      type: 'line'
    },
    title: {
      text: title
    },
    subtitle: {
      text: subtitle
    },
    xAxis: {
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    },
    yAxis: {
      title: {
          text: 'Costo (S/.)'
      }
    },
    plotOptions: {
      line: {
          dataLabels: {
              enabled: true
          },
          enableMouseTracking: false
      }
    },
    series: [{
      name: serie1,
      data: [7.0, 6.9, 9.5, 14.5, 18.4, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]
    }, {
      name: serie2,
      data: [1.0, 2.0, 7.0, 5.0, 11.0, 11.2, 13.7, 11.1, 18.2, 5.3, 6.1, 3.8]
    }, {
      name: serie3,
      data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
    }]
  });
}

function load_bar_graphic_for_general_report(div_id, title, subtitle){
  $('#'+div_id).highcharts({
    chart: {
      type: 'column'
    },
    title: {
      text: title
    },
    subtitle: {
      text: subtitle
    },
    xAxis: {
      categories: [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ]
    },
    yAxis: {
      min: 0,
      title: {
        text: 'Costo (S/.)'
      }
    },
    tooltip: {
      headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
      pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
          '<td style="padding:0"><b>{point.y:.1f} mm</b></td></tr>',
      footerFormat: '</table>',
      shared: true,
      useHTML: true
    },
    plotOptions: {
      column: {
        pointPadding: 0.2,
        borderWidth: 0
      }
    },
    series: [{
      name: 'Programado',
      data: [49.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4]
    }, {
      name: 'Valorizado',
      data: [83.6, 78.8, 98.5, 93.4, 106.0, 84.5, 105.0, 104.3, 91.2, 83.5, 106.6, 92.3]
    }, {
      name: 'Costo Real',
      data: [48.9, 38.8, 39.3, 41.4, 47.0, 48.3, 59.0, 59.6, 52.4, 65.2, 59.3, 51.2]
    }]
  });
}

function load_url_ajax(url, div_id, parameters, loader_flag, render_type){  /*  usar este owo  */
  var url_str = url;
  var div_name = div_id; 
  var type_call = render_type;

  if( loader_flag == 'refresh-body'){
    parameters = {authenticity_token: parameters}
  }
  //title = current_element.attr('title');
  //document.title = (title || document.title);
  $.ajax({
    type: type_call,
    url: url_str,
    async: false,
    data: parameters,
    dataType : 'html',
    beforeSend : function() {
      $("#" + div_name).html('<h1><i class="fa fa-cog fa-spin"></i> Cargando...</h1>');
    },
    success: function(data) {
      if( loader_flag == 'avoid-opacity'){
        $("#" + div_name).html(data).delay(50).animate({
          opacity : '1.0'
        }, 300);
      }else{
        if( loader_flag == 'refresh-body'){
          $('body').html(data);
        } else {
          $("#" + div_name).css({
            opacity : '0.0'
          }).html(data).delay(50).animate({
            opacity : '1.0'
          }, 300);
        }
      }
    },
    error : function(xhr, ajaxOptions, thrownError) {
      container.html('<h4 style="margin-top:10px; display:block; text-align:left"><i class="fa fa-warning txt-color-orangeDark"></i> Error 404! Page not found.</h4>');
    }
  });
}



function delete_to_url(url, div_name, url_index){ /* Method DELETE */
  var url_str = url;
  var div_name = div_name;

  $.ajax({
    url: url_str,
    type: 'DELETE',
    async: false,
    context: document.body,
    success: function(data){
      load_url_ajax(url_index,'content', null, null, 'GET')
      //$("#" + div_name).html(data);
    }
  });
  return false;
}

function append_url_ajax(url, div_id, parameters, loader_flag, render_type){  /*  usar este owo  */

  var url_str = url;
  var div_name = div_id; 
  var type_call = render_type;

  $.ajax({
    type: type_call,
    url: url_str,
    async: false,
    data: parameters
  }).done(function( msg ) {
    $("#" + div_name).append(msg);
  });
  return false;
}

function load_items_delivery_order_ajax(url, div_id, parameters){
  var url_str = url;
  var div_name = div_id; 

  $.ajax({
    type: 'POST',
    url: url_str,
    async: false,
    data: parameters,
    dataType : 'html',
    beforeSend : function() {
      $('#modalLoading').modal('toggle', {
        keyboard: false,
        backdrop: 'static'
      });
    },
    success: function(data) {
      $('#modalLoading').modal('hide');
      $('#'+div_name).html(data);
    },
    error : function(xhr, ajaxOptions, thrownError) {
      container.html('<h4 style="margin-top:10px; display:block; text-align:left"><i class="fa fa-warning txt-color-orangeDark"></i> Error 404! Page not found.</h4>');
    }
  });
}

function show_report_inventory(url, parameters, wurl, wname, wparameters){
  var url_str = url;
  
  alert("Presione OK para visualizar reporte:")
  
  $.ajax({
    type: 'POST',
    url: url_str,
    async: false,
    data: parameters,
    dataType : 'html',
    beforeSend : function() {
      $('#modalLoading').modal('toggle', {
        keyboard: false,
        backdrop: 'static'
      });
    },
    success: function(data) {
      $('#modalLoading').modal('hide');
      //var myWindow = window.open(wurl, wname, wparameters);
      var _form = document.createElement('form');
      _form.action = wurl;
      _form.target = '_blank';
      document.body.appendChild(_form);
      _form.submit();
    },
    error : function(xhr, ajaxOptions, thrownError) {
      container.html('<h4 style="margin-top:10px; display:block; text-align:left"><i class="fa fa-warning txt-color-orangeDark"></i> Error 404! Page not found.</h4>');
    }
  });
}