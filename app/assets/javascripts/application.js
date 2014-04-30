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

$(document).ready(function(){
  $("#left-panel ul li a").click(function(){
    $.company_global_id= $(this).attr("company");
  });

  $.validator.addMethod(
    "greaterThan",
    function(value, element, params) {
        var target = $(params).val();
        var isValueNumeric = !isNaN(parseFloat(value)) && isFinite(value);
        var isTargetNumeric = !isNaN(parseFloat(target)) && isFinite(target);
        if (isValueNumeric && isTargetNumeric) {
            return Number(value) > Number(target);
        }

        if (!/Invalid|NaN/.test(new Date(value))) {
            return new Date(value) > new Date(target);
        }

        return false;
    },
    'Must be greater than {0}.');
  
});

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