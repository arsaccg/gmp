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
//= require twitter/bootstrap
//= require jquery
//= require jquery_ujs 
//= require turbolinks
//= require_tree .
//= require jquery.validate
//= require jquery.validate.additional-methods
//= require jquery.ui.all
//= require jquery.form

var project_selected_data;

$(document).ready(function(){
	
	$(".individual-panel").height(200);
	$(".content-load").height($(document).height()-480);
	$(".botom-load").height(200);
	$(".table-gantt").height($(document).height()-240);
	//$(".inner-white-panel").height($(".side-panel").height()-150);

	window.onresize=function(){
		$(".side-panel").height($(document).height()-60);
	};
});

/* Funcion que permite cargar la informacion devuelta 
   por una peticion GET una url local en un div 
 */
function load_url_ondiv(url, div_name){	/*  usar este owo  */
	var url_str = url;
	var div_name = div_name;

	$("." + div_name).html("<br/><br/><br/><center><img src='/assets/ajax-loader.gif' /></center>")

  $.ajax({
  	url: url_str,
	}).done(function( data ) {
	  $("." + div_name).html(data);
	});

	$(".side-panel").height($(document).height()-80);
	
	return false

}

function post_to_url(url, form_id, response_div){
	var url_str = url;
	var form_id_str = form_id;
	var div_name = response_div;

	$("#" + form_id).ajaxForm(function(){
       alert($(this));
       console.log($(this));
    });

	var str_data = $("#" + form_id).serialize();
	console.log(str_data);

	$("." + div_name).html("<br/><br/><br/><center><img src='/assets/ajax-loader.gif' /></center>")

	$.ajax({
	  type: "POST",
	  url: url_str,
	  data: str_data
	}).done(function( msg ) {
	  $("." + div_name).html(msg);
	});
}

function post_to_url_class(url, form_id, response_div){
	var url_str = url;
	var form_id_str = form_id;
	var div_name = response_div;

	$("." + form_id).ajaxForm(function(){
       alert($(this));
       console.log($(this));
    });

	var str_data = $("." + form_id).serialize();
	console.log(str_data);

	$("." + div_name).html("<br/><br/><br/><center><img src='/assets/ajax-loader.gif' /></center>")

	$.ajax({
	  type: "POST",
	  url: url_str,
	  data: str_data
	}).done(function( msg ) {
	  $("." + div_name).html(msg);
	});
}

function delete_to_url(url, div_name)
{
	var url_str = url;
	var div_name = div_name;

	$("." + div_name).html("<br/><br/><br/><center><img src='/assets/ajax-loader.gif' /></center>")

  	$.ajax({
	  url: url_str,
	  type: 'DELETE'
	}).done(function( data ) {
	  $("." + div_name).html(data);
	});
	return false
}

// Funcion que dibuja el WBS desde una entrada de datos preformateado en JSON

function draw_wbs(url_data, id_response)
	{

		var url_str = url_data;
		var dataTable;


		//Get the json data
		$.ajax({
		  type: "GET",
		  url: url_str
		}).done(function(json) {
		   var data = new google.visualization.DataTable();
	        data.addColumn('string', 'Name');
	        data.addColumn('string', 'Manager');
	        data.addColumn('string', 'ToolTip');
	        data.addRows(json);
		  var chart = new google.visualization.OrgChart(document.getElementById(id_response));
	      chart.draw(data, {allowHtml:true, title: 'WBS', nodeClass: 'node-style'});
		});
	}



function post_response_json(url_request, params){
	var url_str = url_request;
	var obj_response;

	$.ajax({
		type: "POST",
	  	url: url_str,
		data: params
	}).done(function(json){
		obj_response = json;
	});

	return obj_response;
}

Number.prototype.format_currency = function() {
    return this.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "$1,");
};

  function replaceAll(find, replace, str) {
  	str = str.toString();
    return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
  }

  function escapeRegExp(str) {
    return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
  }