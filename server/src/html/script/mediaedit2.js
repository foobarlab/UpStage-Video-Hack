/* media edit2 page -- uses jquery */

var datagrid;
var data = [];
var url;

var clickHandlerEditMedia = null;
var clickHandlerDeleteMedia  = null;

var clickHandlerTestVoice = null;
var clickHandlerTestStream = null;
var clickHandlerTestSound = null;

var previewImageType = null;

function setupMediaEdit2(url_path) {
	
	// set url of this page
	url = url_path;
	
	// enable spinner
	$('#spinner').spin("huge");
	
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
	
	$('#dataLoadingPanel').show();	
	
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
        		$('#dataLoadingPanel').hide();
        	} else {
        		// TODO handle known errors
        		alert("Error while retrieving data: status="+response.status+", timestamp="+ response.timestamp +", data="+response.data);
        		$('#dataLoadingPanel').hide();
        	}
        },
        error: function(XMLHttpRequest, textStatus, errorThrown){
            // TODO handle unknown errors (may be 'no connection')
        	alert("An error occured: textStatus="+textStatus+", errorThrown="+errorThrown);
        	$('#dataLoadingPanel').hide();
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
	       {id: "name", name: "Name", field: "name", width:200},
	       {id: "user", name: "User", field: "user", width:100},
	       {id: "stages", name: "Stages", field: "stages", width:200},
	       {id: "voice", name: "Voice", field: "voice", width:100},
	       {id: "tags", name: "Tags", field: "tags", width:200},
	       {id: "file", name: "File", field: "file", width:200},
	       {id: "date", name: "Date", field: "date", width:200},
	       {id: "type", name: "Type", field: "type", width:100},
	       {id: "medium", name: "Medium", field: "medium", width:100},
	       {id: "thumbnail", name: "Thumbnail", field: "thumbnail", width:200},
	       {id: "key", name: "Key", field: "key", width:200},
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
	
	var key = "";
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
		
		// collect values
		
		key = single_data['key'];
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
		
		// TODO show details
		
	} else {
		
		// TODO hide details
	}
	
	// set text
	
	//$('#detailKey').html(key);
	$('#detailFile').html(file);
	$('#detailName').html(name);
	$('#detailUser').html(user);
	//$('#detailType').html(type);
	$('#detailTags').html(tags);
	$('#detailVoice').html(voice);
	$('#detailStages').html(stages);
	//$('#detailMedium').html(medium);
	//$('#detailThumbnail').html(thumbnail);
	$('#detailDate').html(date);
	
	// remove swf?
	
	if(previewImageType = 'swf') {
		swfobject.removeSWF("flash_container");
	}
	
	// set preview image
	
	var thumbnail_html = '';
	var inject_html = true;
	
	if(single_data != null) {
		
		var thumbnail_extension = getFileExtension(thumbnail);
		switch(thumbnail_extension) {
		
			// handle images
			
			case 'jpg':
			case 'jpeg':
			case 'gif':
			case 'png':
				thumbnail_html = '<img src="'+thumbnail+'" alt="'+ name +'" />';
				previewImageType = 'img';
				break;
		
			// handle shockwave flash
			
			case 'swf':
				$('#thumbnailPreview').html('<div id="flash_container"></div>');
				inject_html = false;
				swfobject.embedSWF(thumbnail, "flash_container", "290", "190", "9.0.0", "/script/swfobject/expressInstall.swf");
				previewImageType = 'swf';
				// TODO add alternative content (download flash player)
				break;
		
			// default: missing icon
				
			default:
				thumbnail_html = '<img src="/image/icon/icon-question-sign.png" alt="preview not available" />';
				previewImageType = 'img';
		}
	} else {
		previewImageType = null;
	}
	
	if(inject_html) $('#thumbnailPreview').html(thumbnail_html);
	
	// setup test buttons
	
	// unbind event handlers
	$("#buttonTestVoice").unbind('click',clickHandlerTestVoice);
	$("#buttonTestStream").unbind('click',clickHandlerTestStream);
	$("#buttonTestSound").unbind('click',clickHandlerTestSound);
	
	// hide buttons
	$('#buttonTestVoice').hide();
	$('#buttonTestStream').hide();
	$('#buttonTestSound').hide();
	
	if(single_data != null) {
		
		// show buttons depending on type
		switch(type) {
		
			case 'avatar':
				$('#buttonTestVoice').show();
				
				// create click handler
				clickHandlerTestVoice = function(e) {
					log.debug("clickHandlerTestVoice: click: #buttonTestVoice, selectedRow="+selectedRow);
					var key = data[selectedRow]['key'];
					log.debug("clickHandlerTestVoice: about to do a voice test for key="+key);
					
					// TODO run test
					
					alert("TestVoice");
				}
				
				// bind button to click event
				$("#buttonTestVoice").bind('click', clickHandlerTestVoice);
			
				break;
			
			case 'audio':
				$('#buttonTestSound').show();
				
				// create click handler
				clickHandlerTestSound = function(e) {
					log.debug("clickHandlerTestSound: click: #buttonTestSound, selectedRow="+selectedRow);
					var key = data[selectedRow]['key'];
					log.debug("clickHandlerTestSound: about to do a sound test for key="+key);
					
					// TODO run test
					
					alert("TestSound");
				}
				
				// bind button to click event
				$("#buttonTestSound").bind('click', clickHandlerTestSound);
				
				break;
		
		}
		
		// show buttons depending on medium
		switch(medium) {
			
			case 'stream':
				$('#buttonTestStream').show();
				
				// create click handler
				clickHandlerTestStream = function(e) {
					log.debug("clickHandlerTestStream: click: #buttonTestStream, selectedRow="+selectedRow);
					var key = data[selectedRow]['key'];
					log.debug("clickHandlerTestStream: about to do a stream test for key="+key);
					
					// TODO run test
					
					alert("TestStream");
				}
				
				// bind button to click event
				$("#buttonTestStream").bind('click', clickHandlerTestStream);
				
				break;
				
		}
		
	}
	
	// display type in headline
	
	var headline = '';
	if(single_data != null) {
		headline = type;
		if (medium != '') {
			headline += ' ('+medium+')';
		}
	} 
	
	$('#displayType').text(headline);
	
	// show or hide panels
	
	if(single_data != null) {
		
		// narrow datagrid
		$('#dataPanel').css('width','700px');
		
		// show details panel
		$('#detailsPanel').show();
		
	} else {
		
		// extend datagrid (revert to default defined in css)
		$('#dataPanel').css('width','');
		
		// hide details panel
		$('#detailsPanel').hide();
	}
	
}

/* helper functions */

function getFileExtension(filename) {
	var ext = /^.+\.([^.]+)$/.exec(filename);
	return ext == null ? "" : ext[1];
}
