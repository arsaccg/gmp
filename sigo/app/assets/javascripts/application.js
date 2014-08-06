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

function load_graphic(div_id, semana1, semana2, semana3, semana4, semana5, semana6, semana7, semana8, semana9, semana10, theoretical_value, valor1, valor2, valor3, valor4, valor5, valor6, valor7, valor8, valor9, valor10){
  theoretical_value = parseFloat(theoretical_value)
  valor1 = parseFloat(valor1)
  valor2 = parseFloat(valor2)
  valor3 = parseFloat(valor3)
  valor4 = parseFloat(valor4)
  valor5 = parseFloat(valor5)
  valor6 = parseFloat(valor6)
  valor7 = parseFloat(valor7)
  valor8 = parseFloat(valor8)
  valor9 = parseFloat(valor9)
  valor10 = parseFloat(valor10)
  $('#'+div_id).highcharts({
    title: {
        text: 'Promedio Semanal Consumo de Combustible',
        x: -20 //center
    },
    subtitle: {
        text: 'Gráfico Histograma Semanal',
        x: -20
    },
    xAxis: {
        categories: [semana1, semana2, semana3, semana4, semana5, semana6,
            semana7, semana8, semana9, semana10]
    },
    yAxis: {
        title: {
            text: 'Consumo de Combustible'
        },
        plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
        }]
    },
    tooltip: {
        valueSuffix: 'gln/hr'
    },
    legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle',
        borderWidth: 0
    },
    series: [{
        name: 'Reales',
        data: [valor1, valor2, valor3, valor4, valor5, valor6, valor7, valor8, valor9, valor10]
    }, {
        name: 'Teórico',
        data: [theoretical_value, theoretical_value, theoretical_value, theoretical_value, theoretical_value, theoretical_value, theoretical_value, theoretical_value, theoretical_value, theoretical_value]
    }]
  });
}

function load_graphic_for_weekly_report(div_id,week1,week2,week3,week4,week5,week6,week7,week8,week9,week10,title,series2,unit){
  $('#'+div_id).highcharts({
    chart: {
        type: 'area'
    },
    title: {
        text: 'Reporte Semanal ' + title,
    },
    subtitle: {
        text: 'Desde ' + week1 + ' hasta ' + week10
    },
    xAxis: {
        categories: [week1, week2, week3, week4, week5, week6, week7, week8, week9, week10],
        tickmarkPlacement: 'on',
        title: {
            enabled: false
        }
    },
    yAxis: {
        title: {
            text: unit
        },
        labels: {
            formatter: function() {
                return this.value / 1000;
            }
        }
    },
    tooltip: {
        shared: true,
        valueSuffix: ' millions'
    },
    plotOptions: {
        area: {
            stacking: 'normal',
            lineColor: '#666666',
            lineWidth: 1,
            marker: {
                lineWidth: 1,
                lineColor: '#666666'
            }
        }
    },
    series: series2
  });
}

function load_lineal_graphic_for_general_report(div_id, title, subtitle, serie1, serie2, serie3, data_serie1, data_serie2, data_serie3){
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
      categories: ['ENE.12', 'FEB.12', 'MAR.12', 'ABR.12', 'MAY.12', 'JUN.12', 'JUL.12', 'AGO.12', 'SET.12', 'OCT.12', 'NOV.12', 'DIC.12', 'ENE.13', 'FEB.13', 'MAR.13', 'ABR.13', 'MAY.13', 'JUN.13', 'JUL.13', 'AGOS.13', 'SET.13', 'OCT.13', 'NOV.13', 'DIC.13', 'ENE.14']
    },
    yAxis: {
      title: { text: 'Costo (S/.)' }
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
      data: data_serie1
    }, {
      name: serie2,
      data: data_serie2
    }, {
      name: serie3,
      data: data_serie3
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
        'AGOS.13', 'SET.13', 'OCT.13', 'NOV.13', 'DIC.13', 'ENE.14'
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
      data: [3874189.278, 4045632.531, 3586762.657, 2981715.844, 3078316.592, 2402520.912]
    }, {
      name: 'Valorizado',
      data: [1033305.21, 1658607.79, 1880477.29, 2149285.52, 1226151.00131, 1511088.597]
    }, {
      name: 'Costo Real',
      data: [764479, 952670.251, 858321.99, 1325361.336, 1330032.980, 1140183.798]
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

function load_modal_ajax(url, div_id_new, div_id_previous, parameters, loader_flag, render_type){
  var url_str = url;
  var div_name_new = div_id_new; 
  var type_call = render_type;
  var div_name_old = div_id_previous; 
  //title = current_element.attr('title');
  //document.title = (title || document.title);
  $.ajax({
    type: type_call,
    url: url_str,
    async: false,
    data: parameters,
    dataType : 'html',
    beforeSend : function() {
      $("#" + div_name_new).html('<h1><i class="fa fa-cog fa-spin"></i> Cargando...</h1>');
    },
    success: function(data) {
      $("#" + div_name_old).modal('hide');
      $("#" + div_name_new).modal('toggle');
      $("#" + div_name_new).html(data);
    },
    error : function(xhr, ajaxOptions, thrownError) {
      container.html('<h4 style="margin-top:10px; display:block; text-align:left"><i class="fa fa-warning txt-color-orangeDark"></i> Error 404! Page not found.</h4>');
    }
  });
}

function load_file_ajax(dom_element, url, type_call, parameters, div_name){
  
  $(dom_element).fileupload({
    url: url,
    method: type_call,
    formData: parameters,
    onSuccess:function(files,data,xhr) {
      $("#" + div_name).css({
        opacity : '0.0'
      }).html(data).delay(50).animate({
        opacity : '1.0'
      }, 300);
    },
    onError: function(files,status,errMsg)
    {
      console.log(files);
      console.log(errMsg);
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


function bar_graph_category(div, categoria, series2, title_c, tipo, abrev, suffix){
  var arreglo = categoria.split(',')
  console.log(suffix);

  $('#'+div).highcharts({
    chart: {
      zoomType: 'xy'
    },
    title: {
      text: title_c
    },
    xAxis: [{
      categories: arreglo
    }],
    yAxis: [
      { // First yAxis
        title: {
          text: '',
          style: {
            color: Highcharts.getOptions().colors[0]
          }
        }

      },
      { // Secondary yAxis
        gridLineWidth: 0,
        title: {
          text: tipo,
          style: {
            color: Highcharts.getOptions().colors[18]
          }
        },
        labels: {
          format: '{value} '+abrev,
          style: {
            color: Highcharts.getOptions().colors[18]
          }
        }

      },
      { // Third yAxis
        title: {
          text: '',
          style: {
            color: Highcharts.getOptions().colors[0]
          }
        }
      }],
    
    tooltip: {
      shared: true,
      headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
      pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + '<td style="padding:0"><b>{point.y:.1f}'+suffix+'</b></td></tr>',
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
    legend: {
        layout: 'vertical',
        align: 'left',
        x: 120,
        verticalAlign: 'top',
        y: 80,
        floating: true,
        backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'
    },
    series: series2
  });
}