/* media edit2 page -- uses jquery */

const MEDIA_TYPE_IMAGE = 'image';
const MEDIA_TYPE_FLASH = 'flash';
const MEDIA_TYPE_AUDIO = 'audio';
const MEDIA_TYPE_STREAM = 'stream';

//global variables

var url;	// current url for the page
var user;	// current user

var selectedMediaData = null;	// currently selected media dataset

var datagrid;
var data = [];

var clickHandlerEditMedia = null;
var clickHandlerDeleteMedia  = null;
var clickHandlerPreviewMedia = null;
var clickHandlerAssignMedia = null;
var clickHandlerDownloadMedia = null;
var clickHandlerTagMedia = null;

var clickHandlerConfirmDelete = null;

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
	       {id: "file_original", name: "File (Original)", field: "file_original", width:200},
	       {id: "date", name: "Date", field: "date", width:200},
	       {id: "type", name: "Type", field: "type", width:100},
	       {id: "medium", name: "Medium", field: "medium", width:100},
	       {id: "thumbnail", name: "Thumbnail", field: "thumbnail", width:200},
	       {id: "thumbnail_original", name: "Thumbnail (Original)", field: "thumbnail_original", width:200},
	       {id: "thumbnail_icon", name: "Thumbnail (Icon)", field: "thumbnail_icon", width:200},
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
			
			// unbind button controls
			$("#buttonEditMedia").unbind('click',clickHandlerEditMedia);
			$("#buttonAssignMedia").unbind('click',clickHandlerAssignMedia);
			$("#buttonDeleteMedia").unbind('click',clickHandlerDeleteMedia);
			$("#buttonDownloadMedia").unbind('click',clickHandlerDownloadMedia);
			$("#buttonTagMedia").unbind('click',clickHandlerTagMedia);
			
			if (rows.length == 1){
	
				// single row selected
				
				selectedRow = rows[0];
				showDetails(data[selectedRow]);
				
				// set current selected media data
				
				selectedMediaData = data[selectedRow];
				
				// create click handlers
				
				clickHandlerEditMedia = function(e) {
					log.debug("clickHandlerEditMedia: click: #buttonEditMedia, key="+selectedMediaData['key']);
					
					// hide all edit panels
					
					$('#editPanelAvatar').hide();
					$('#editPanelProp').hide();
					$('#editPanelBackdrop').hide();
					$('#editPanelAudio').hide();
					$('#editPanelVideo').hide();
					
					// show edit panel depending on type of media
					
					var type = selectedMediaData['type'];
					var medium = selectedMediaData['medium'];
					
					switch(type) {
						case 'avatar':
							if (medium == 'video') {
								$('#editPanelVideo').show();
							} else {
								$('#editPanelAvatar').show();
							}
							break;
						case 'prop':
							$('#editPanelProp').show();
							break;
						case 'backdrop':
							$('#editPanelBackdrop').show();
							break;
						case 'audio':
							$('#editPanelAudio').show();
							break;
					}
					
					// show edit panel
					
					$.colorbox({
						animation:false,
						returnFocus: false,
						transition: 'fade',
						scrolling: false,
						opacity: 0.5,
						open: true,
						initialWidth: 700,
						initialHeight: 450,
						width: 700,
						height: 450,
						inline: true,
						href: "#editMediaPanel",
						
						// hide loading indicator:
						onOpen: function(){ $("#colorbox").css("opacity", 0); },
				        onComplete: function(){ $("#colorbox").css("opacity", 1); }
					});
					
				};
				
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
						animation:false,
						returnFocus: false,
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
					
				};
				
				clickHandlerAssignMedia = function(e) {
					
					log.debug("clickHandlerAssignMedia: click: #buttonAssignMedia, key="+selectedMediaData['key']);
					
					// TODO
					
					// show assign panel
					$.colorbox({
						animation: false,
						returnFocus: false,
						transition: 'fade',
						scrolling: false,
						opacity: 0.5,
						open: true,
						initialWidth: 500,
						initialHeight: 550,
						width: 500,
						height: 550,
						inline: true,
						href: "#assignMediaPanel",
						
						// hide loading indicator:
						onOpen: function(){ $("#colorbox").css("opacity", 0); },
				        onComplete: function(){ $("#colorbox").css("opacity", 1); }
					});
					
				};
				
				clickHandlerTagMedia = function(e) {
					
					log.debug("clickHandlerTagMedia: click: #buttonTagMedia, key="+selectedMediaData['key']);
					
					// TODO
					
					// show tag panel
					$.colorbox({
						animation: false,
						returnFocus: false,
						transition: 'fade',
						scrolling: false,
						opacity: 0.5,
						open: true,
						initialWidth: 500,
						initialHeight: 350,
						width: 500,
						height: 350,
						inline: true,
						href: "#tagMediaPanel",
						
						// hide loading indicator:
						onOpen: function(){ $("#colorbox").css("opacity", 0); },
				        onComplete: function(){ $("#colorbox").css("opacity", 1); }
					});
					
				};
				
				clickHandlerDownloadMedia = function(e) {
					log.debug("clickHandlerDownloadMedia: click: #buttonDownloadMedia, key="+selectedMediaData['key']);
					
					var downloadFile = selectedMediaData['file'];
					if(downloadFile != '') {
						var downloadUrl = downloadFile+"?download=true";
						$("#downloadIFrame").attr("src",downloadUrl);
					}
				};
				
				// bind button controls to click event
				
				$("#buttonEditMedia").bind('click', clickHandlerEditMedia);
				$("#buttonAssignMedia").bind('click', clickHandlerAssignMedia);
				$("#buttonDeleteMedia").bind('click', clickHandlerDeleteMedia);
				$("#buttonTagMedia").bind('click', clickHandlerTagMedia);
				
				// enable/disable download button
				var downloadFile = selectedMediaData['file'];
				
				// HACK: images do not work therefore disable download too
				var extension = getFileExtension(downloadFile);
				switch(extension) {
					case 'jpg':
					case 'jpeg':
					case 'gif':
					case 'png':
						downloadFile = '';
				}
				
				if(downloadFile != '') {
					$("#buttonDownloadMedia").bind('click', clickHandlerDownloadMedia);
					$("#buttonDownloadMedia").removeAttr("disabled");
				} else {
					clickHandlerDownloadMedia = null;
					$("#buttonDownloadMedia").attr("disabled", "disabled");
				}
				
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
	var file_original = "";
	var name = "";
	var user = "";
	var type = "";
	var tags = "";
	var voice = "";
	var stages = "";
	var medium = "";
	var thumbnail = "";
	var thumbnail_original = "";
	var thumbnail_icon = "";
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
		thumbnail_original = single_data['thumbnail_original'];
		thumbnail_icon = single_data['thumbnail_icon'];
		file = single_data['file'];
		file_original = single_data['file_original'];
		date = single_data['date'];
	}
	
	// set text in details table
	$('#detailFile').html('<a href="'+file+'" target="_blank">'+file+'</a>');
	$('#detailType').html((medium != '' ? type+' ('+medium+')' : type));
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
	$("#previewPanelStream").hide();
	
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
				
				// additional stream available?
				if(medium == 'stream') {
					$("#previewPanelStream").show();
				}
				break;
				
			// audio types
			case 'mp3':
				previewType = self.MEDIA_TYPE_AUDIO;
				$("#previewPanelAudio").show();
				break;
				
			// no file existant
			default:
				if(medium == 'stream') {
					// stream only
					previewType = self.MEDIA_TYPE_STREAM;
					$("#previewPanelStream").show();
				} else {
					//no preview available
					previewType = null;
				}
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
				// do we have a thumbnail icon provided? if yes, use it in favor of image thumbnail
				var thumbnail_icon = single_data['thumbnail_icon'];
				if(thumbnail_icon != '') {
					thumbnail_html = '<i class="'+thumbnail_icon+'"></i>';
				} else {
					thumbnail_html = '<img src="'+thumbnail+'" alt="'+ name +'" />';
				}
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
				//thumbnail_html = '<img src="/image/icon/icon-warning-sign.png" alt="preview not available" />';
				thumbnail_html = '<i class="icon-warning-sign"></i>';
				previewThumbnailType = null;
		}
		
		$('#thumbnailPreview').html(thumbnail_html);
		
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
		
		// remove click handlers for preview
		$("#buttonPreviewMedia").unbind('click',clickHandlerPreviewMedia);
		
		if(previewType != null) {
			
			// define colorbox
			var previewColorbox = {
					transition: 'fade',
					scrolling: false,
					opacity: 0.5,
					open: false,
					initialWidth: 290,
					initialHeight: 190,
					inline:true,
					href: "#previewMediaPanel",
					animation: false,
					returnFocus: false,
					width: previewWindowWidth,
					height: previewWindowHeight,
					// hide loading indicator:
					onOpen: function(){ $("#colorbox").css("opacity", 0); },
			        onComplete: function(){ $("#colorbox").css("opacity", 1); }
				
					// TODO add onClose handler to remove all preview data
					// TODO add onComplete handler to add all preview data
			};
			
			// set handler for clicking on thumbnail
			$("#previewLink").addClass('inline');
			$("#previewLink.inline").colorbox(previewColorbox);
			
			// set handler for clicking on preview (button)
			clickHandlerPreviewMedia = function(e) {
				log.debug("clickHandlerPreviewMedia: click: #buttonPreviewMedia, key="+selectedMediaData['key']);
				
				// open confirmation dialog
				$.colorbox(previewColorbox);
			}
		
			// bind click handler to preview button
			$("#buttonPreviewMedia").bind('click',clickHandlerPreviewMedia);
		}
		
	} else {

		previewThumbnailType = null;	// reset thumbnail preview type
		
	}
	
	// display name in headline
	
	$('#displayName').text(name);
	
	// show or hide panels
	
	if(single_data != null) {
		
		// narrow datagrid
		$('#dataPanel').css('width','60%');
		
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
