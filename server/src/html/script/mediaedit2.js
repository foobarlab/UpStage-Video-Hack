/* media edit2 page -- uses jquery */

var datagrid;
var data = [];
var url;
var clickHandlerEditMedia = null;
var clickHandlerDeleteMedia  = null;

function setupMediaEdit2(url_path) {
	
	// set url of this page
	url = url_path;
	
	// setup data grid
	setupDataGrid();
	
	// register button handlers
	
	$("#buttonUpdateView").click(function(e){
		log.debug("click: #buttonUpdateView");
		callAjaxUpdateData();
	});

	$("#buttonResetView").click(function(e){
		log.debug("click: #buttonResetView");
		$("#filterUser").val("");
		$("#filterStage").val("");
		$("#filterType").val("");
		$("#filterMedium").val("");
		$("#filterName").val("");
		$("#filterTags").val("");
		callAjaxUpdateData();
	});
	
	// initial update data
	callAjaxUpdateData();
	
}

/* do ajax 'updata_data' call */
function callAjaxUpdateData() {
	
	log.debug("callAjaxUpdateData()");
	
	$.ajax({type: "POST",
		url: url+"?ajax=update_data",
		data: {
        	'filter_user': $("#filterUser").val(),
        	'filter_stage': $("#filterStage").val(),
        	'filter_type': $("#filterType").val(),
        	'filter_medium': $("#filterMedium").val(),
        },
        success: function(response) {
        	//alert("Response Success: response="+response);
        	if(response.status == 200) {
        		updateData(response.data);
        	} else {
        		// TODO handle known errors
        		alert("Error while retrieving data: status="+response.status+", timestamp="+ response.timestamp +", data="+response.data);
        	}
        },
        error: function(XMLHttpRequest, textStatus, errorThrown){
            // TODO handle unknown errors (may be 'no connection')
        	alert("An error occured: textStatus="+textStatus+", errorThrown="+errorThrown);
        },
	});
	
}

function callAjaxDeleteMedia(key) {
	
	log.debug("callAjaxDeleteMedia(): key="+key);
	
	// TODO
	
	alert("delete " + key);
}

function callAjaxGetDetails(key) {
	
	log.debug("callAjaxGetDetails(): key="+key);
	
	// TODO
	
}

function testCallback(params) {
	alert("testCallback: params=" + params);
}

function setupDataGrid() {
	
	log.debug("setupDataGrid()");
	
	var columns = [
	       {id: "key", name: "Key", field: "key", width:200},
	       {id: "name", name: "Name", field: "name", width:200},
	       {id: "user", name: "User", field: "user", width:100},
	       {id: "type", name: "Type", field: "type", width:100},
	       {id: "tags", name: "Tags", field: "tags", width:200},
	       {id: "voice", name: "Voice", field: "voice", width:100},
	       {id: "stages", name: "Stages", field: "stages", width:200},
	       {id: "medium", name: "Medium", field: "medium", width:100},
	       {id: "thumbnail", name: "Thumbnail", field: "thumbnail", width:200},
	       {id: "file", name: "File", field: "file", width:200},
	       {id: "date", name: "Date", field: "date", width:200},
       ];

	var options = {
			enableCellNavigation: true,
			enableColumnReorder: false,
			editable: false,
		    multiSelect: false,
	};

	$(function () {
		
		datagrid = new Slick.Grid("#dataGrid", data, columns, options);
		datagrid.setSelectionModel(new Slick.RowSelectionModel());
				
		// add selection event listener
		datagrid.onSelectedRowsChanged.subscribe(function(e,args) {
			var rows = datagrid.getSelectedRows();
			log.debug("selected: rows="+rows);
			if(typeof rows === 'undefined') return;
			
			// unbind buttons
			$("#buttonEditMedia").unbind('click',clickHandlerEditMedia);
			$("#buttonDeleteMedia").unbind('click',clickHandlerDeleteMedia);
			
			if (rows.length == 1){
	
				// single row selected
				
				selectedRow = rows[0];
				showDetails(data[selectedRow]);
				
				// create click handlers
				
				clickHandlerEditMedia = function(e) {
					log.debug("clickHandlerEditMedia: click: #buttonEditMedia, selectedRow="+selectedRow);
					// TODO
					alert("edit");
				}
				
				clickHandlerDeleteMedia = function(e) {
					log.debug("clickHandlerDeleteMedia: click: #buttonDeleteMedia, selectedRow="+selectedRow);
					var key = data[selectedRow]['key'];
					log.debug("clickHandlerDeleteMedia: about to delete key="+key);
					// TODO add confirmation dialog (jqueryui?)
					callAjaxDeleteMedia(key);
				}
				
				// bind buttons to click event
				
				$("#buttonEditMedia").bind('click', clickHandlerEditMedia);
				$("#buttonDeleteMedia").bind('click', clickHandlerDeleteMedia);
				
			} else if (rows.length >1) {
				
				// multiple rows selected
				
				showDetails(null);
				datagrid.getSelectionModel().setSelectedRanges([]);	// deselect any selections
				datagrid.invalidate();
			} else {
				
				// no row selected
				
				showDetails(null);
			}
		});
		
	});
	
}

function updateData(update_data) {
	
	log.debug("updateData(): update_data="+update_data);
	
	if (update_data != null) {
		data = update_data;
	} else {
		data = [];
	}
	datagrid.setData(data,true);
	datagrid.getSelectionModel().setSelectedRanges([]);	// deselect any selections
	datagrid.invalidate();
}

function showDetails(single_data) {
	
	log.debug("showDetails(): single_data="+single_data);
	
	var id = "";
	var file = "";
	var name = "";
	var user = "";
	var type = "";
	var tags = "";
	var voice = "";
	var stages = "";
	var medium = "";
	var thumbnail = "";
	var file = "";
	var date = "";
	
	// extract data
	if(single_data != null) {
		id = single_data['id'];
		id = single_data['file'];
		name = single_data['name'];
		user = single_data['user'];
		type = single_data['type'];
		tags = single_data['tags'];
		voice = single_data['voice'];
		stages = single_data['stages'];
		medium = single_data['medium'];
		thumbnail = single_data['thumbnail'];
		file = single_data['file'];
		date = single_data['date'];
	}
	
	$('#detailID').html(id);
	$('#detailFile').html(file);
	$('#detailName').html(name);
	$('#detailUser').html(user);
	$('#detailType').html(type);
	$('#detailTags').html(tags);
	$('#detailVoice').html(voice);
	$('#detailStages').html(stages);
	$('#detailMedium').html(medium);
	$('#detailThumbnail').html(thumbnail);
	$('#detailFile').html(file);
	$('#detailDate').html(date);
	
}