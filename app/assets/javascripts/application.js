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

function load_url_ajax(url, div_id, parameters, loader_flag, render_type){  /*  usar este owo  */

  var url_str = url;
  var div_name = div_id; 
  var type_call = render_type;

  $.ajax({
    type: type_call,
    url: url_str,
    async: false,
    data: parameters
  }).done(function( msg ) {
    $("#" + div_name).html(msg);
  });
  return false;
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