/* media edit2 page -- uses jquery */

const MEDIA_TYPE_IMAGE = 'image';
const MEDIA_TYPE_FLASH = 'flash';
const MEDIA_TYPE_AUDIO = 'audio';
//const MEDIA_TYPE_STREAM = 'stream';

//global variables

var url;	// current url for the page
var user;	// current user

var selectedMediaData = null;	// currently selected media dataset

var datagrid;
var data = [];

var clickHandlerEditMedia = null;
var clickHandlerDeleteMedia  = null;

var clickHandlerConfirmDelete = null;

var clickHandlerTestVoice = null;
var clickHandlerTestStream = null;
var clickHandlerTestSound = null;

var previewType = null;
var previewThumbnailType = null;

function setupMediaEdit2(url_path,current_user) {
	
	// set global variables
	url = url_path;
	user = current_user;

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
		
		setCurrentUserInFilter();	// set default user
		callAjaxUpdateData();
	});
	
	setCurrentUserInFilter();	// set default user
	callAjaxUpdateData();		// set initial data
	
}

function setCurrentUserInFilter() {
	
	log.debug("setCurrentUserInFilter(): user="+user);
	
	// check if user is available as value in dropdown menu
	var found = false;
	$('#filterUser option').each(function(){
	    if (this.value == user) {
	        found = true;
	        return false;
	    }
	});
	
	if(found) {
		log.debug("setCurrentUserInFilter(): user was found in dropdown, preselect as default");
		$("#filterUser").val(user);
	} else {
		log.debug("setCurrentUserInFilter(): user was not found in dropdown, not preselected");
	}
}

/* do ajax 'updata_data' call */
function callAjaxUpdateData() {
	
	log.debug("callAjaxUpdateData()");
	
	// hide details
	showDetails(null);
	
	// show loading panel
	$('#dataLoadingPanel').show();	
	$('#spinner').spin("huge");
	
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
        		
        		// hide loading panel
        		$('#spinner').stop();
        		$('#dataLoadingPanel').hide();
        		
        	} else {
        		// TODO handle known errors
        		alert("Error while retrieving data: status="+response.status+", timestamp="+ response.timestamp +", data="+response.data);
        		updateData(null);
        		
        		// hide loading panel
        		$('#spinner').stop();
        		$('#dataLoadingPanel').hide();
        	}
        },
        error: function(XMLHttpRequest, textStatus, errorThrown){
            // TODO handle unknown errors (may be 'no connection')
        	alert("An error occured: textStatus="+textStatus+", errorThrown="+errorThrown);
        	updateData(null);
        	
        	// hide loading panel
        	$('#spinner').stop();
        	$('#dataLoadingPanel').hide();
        },
	});
	
}

function callAjaxDeleteMedia(key,deleteIfInUse) {
	log.debug("callAjaxDeleteMedia(): key="+key+", deleteIfInUse="+deleteIfInUse);
	// TODO
	alert("delete key: " + key + ", deleteIfInUse: " + deleteIfInUse);
}

/*
function callAjaxGetDetails(key) {
	log.debug("callAjaxGetDetails(): key="+key);
	// TODO
}
*/

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
				
				// set current selected media data
				
				selectedMediaData = data[selectedRow];
				
				// create click handlers
				
				clickHandlerEditMedia = function(e) {
					log.debug("clickHandlerEditMedia: click: #buttonEditMedia, key="+selectedMediaData['key']);
					// TODO
					alert("edit");
				}
				
				clickHandlerDeleteMedia = function(e) {
					log.debug("clickHandlerDeleteMedia: click: #buttonDeleteMedia, key="+selectedMediaData['key']);
					
					// unbind confirm button first
					$("#buttonConfirmDelete").unbind('click',clickHandlerConfirmDelete);
					
					// set click handler for confirmation dialog
					clickHandlerConfirmDelete = function(e) {
						log.debug("clickHandlerConfirmDelete: click: #buttonConfirmDelete, key="+selectedMediaData['key']);
						// get if we want to delete even if in use
						var deleteIfInUse = $("#deleteEvenIfInUse").prop('checked');
						// actually delete the media
						callAjaxDeleteMedia(selectedMediaData['key'],deleteIfInUse);
						
						// TODO close confirmation dialog?
					}
					
					// bind click handler for final deletion
					$("#buttonConfirmDelete").bind('click',clickHandlerConfirmDelete);
					
					// set media name in confirmation dialog
					$("#deleteMediaName").html(selectedMediaData['name']);
					
					// reset checkbox (delete even if in use)
					$("#deleteEvenIfInUse").attr('checked', false);
					
					// open confirmation dialog
					$.colorbox({
						transition: 'fade',
						scrolling: false,
						opacity: 0.5,
						open: true,
						initialWidth: 0,
						initialHeight: 0,
						inline: true,
						href: "#deleteMediaPanel",
						
						// hide loading indicator:
						onOpen: function(){ $("#colorbox").css("opacity", 0); },
				        onComplete: function(){ $("#colorbox").css("opacity", 1); }
					});
					
				}
				
				// bind buttons to click event
				
				$("#buttonEditMedia").bind('click', clickHandlerEditMedia);
				$("#buttonDeleteMedia").bind('click', clickHandlerDeleteMedia);
				
			} else if (rows.length >1) {
				
				// multiple rows selected
				
				showDetails(null);
				datagrid.getSelectionModel().setSelectedRanges([]);	// deselect any selections
				datagrid.invalidate();
				
				// TODO allow deletion of multiple selected media?
				
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
	
	// reset data
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
	
	// extract given data
	if(single_data != null) {
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
	}
	
	// set text
	$('#detailFile').html(file);
	$('#detailName').html(name);
	$('#detailUser').html(user);
	$('#detailTags').html(tags);
	$('#detailVoice').html(voice);
	$('#detailStages').html(stages);
	$('#detailDate').html(date);
	

	// TODO remove previous active previews

	// hide all preview type
	$("#previewPanelImage").hide();
	$("#previewPanelFlash").hide();
	$("#previewPanelAudio").hide();
	
	// set preview type
	if(single_data != null) {
		
		// check file type
		var file_extension = getFileExtension(file);
		switch(file_extension) {
		
			// image types
			case 'jpg':
			case 'jpeg':
			case 'gif':
			case 'png':
				previewType = self.MEDIA_TYPE_IMAGE;
				$("#previewPanelImage").show();
				break;
				
			// swf type
			case 'swf':
				previewType = self.MEDIA_TYPE_FLASH;
				$("#previewPanelFlash").show();
				break;
				
			// audio types
			case 'mp3':
				previewType = self.MEDIA_TYPE_AUDIO;
				$("#previewPanelAudio").show();
				break;
				
			// default: no preview available
			default:
				previewType = null;
		}
		
	} else {
		
		previewType = null;	// reset preview type
	
	}
	
	
	
	// remove thumbnail preview colorbox handler
	$("#previewLink.inline").removeClass('inline cboxElement');
	
	// remove existing swf?
	if(previewThumbnailType == self.MEDIA_TYPE_FLASH) {
		$('#thumbnailPreview').flash().remove();
	}
	
	// set new thumbnail preview image
	var thumbnail_html = '';
	if(single_data != null) {
		
		var thumbnail_extension = getFileExtension(thumbnail);
		switch(thumbnail_extension) {
		
			// handle images
			case 'jpg':
			case 'jpeg':
			case 'gif':
			case 'png':
				thumbnail_html = '<img src="'+thumbnail+'" alt="'+ name +'" />';
				previewThumbnailType = self.MEDIA_TYPE_IMAGE;
				break;
		
			// handle shockwave flash
			case 'swf':
				thumbnail_html = $.flash.create({
					swf: thumbnail,
					height: 190,
					width: 290,
					allowFullScreen: true,
					wmode: "transparent",
					menu: false,
					play: true,
					encodeParams: true,
					flashvars: {},
					hasVersion: 6, // requires minimum Flash 6
					expressInstaller: '/script/swfobject/expressInstall.swf',
					hasVersionFail: function (options) {
						log.debug(options);
						//return false; // returning false means the expressInstaller document will not be used
						return true; // would have let the expressInstaller document be used
					}
				});
				
				previewThumbnailType = self.MEDIA_TYPE_FLASH;
				
				// TODO add alternative content (download flash player)
				
				break;
		
			// default: missing icon
			default:
				thumbnail_html = '<img src="/image/icon/icon-question-sign.png" alt="preview not available" />';
				previewThumbnailType = null;
		}
		
		$('#thumbnailPreview').html(thumbnail_html);
		
		/*
		// register thumbnail preview window handler for images and swf
		if(previewThumbnailType != null) {
			$("#previewLink").addClass('inline');
			$("#previewLink.inline").colorbox({
				transition: 'fade',
				scrolling: false,
				opacity: 0.5,
				open: false,
				initialWidth: 290,
				initialHeight: 190,
				inline:true,
				//animation: false,
				width: 750,
				height: 550,
				// hide loading indicator:
				onOpen: function(){ $("#colorbox").css("opacity", 0); },
		        onComplete: function(){ $("#colorbox").css("opacity", 1); }
			});
		}
		*/
		
		// set preview window parameters depending on media
		var previewWindowWidth = 750;
		var previewWindowHeight = 550;
		
		switch(previewType) {
			case self.MEDIA_TYPE_IMAGE:
				// use defaults
				break;
			case self.MEDIA_TYPE_FLASH:
				// use defaults
				break;
			case self.MEDIA_TYPE_AUDIO:
				previewWindowWidth = 400;
				previewWindowHeight = 250;
				break;
		}
		
		if(previewThumbnailType != null) {
			$("#previewLink").addClass('inline');
			$("#previewLink.inline").colorbox({
				transition: 'fade',
				scrolling: false,
				opacity: 0.5,
				open: false,
				initialWidth: 290,
				initialHeight: 190,
				inline:true,
				animation: false,
				width: previewWindowWidth,
				height: previewWindowHeight,
				// hide loading indicator:
				onOpen: function(){ $("#colorbox").css("opacity", 0); },
		        onComplete: function(){ $("#colorbox").css("opacity", 1); }
			
				// TODO add onClose handler to remove all preview data
				// TODO add onComplete handler to add all preview data
			
			});
		}
		
	} else {

		previewThumbnailType = null;	// reset thumbnail preview type
		
	}
	
	
	
	
	// TODO: test buttons will be on preview window
	
	/*
	
	// setup test buttons
	
	// unbind event handlers
	$("#buttonTestVoice").unbind('click',clickHandlerTestVoice);
	/$("#buttonTestStream").unbind('click',clickHandlerTestStream);
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
	
	*/
	
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
