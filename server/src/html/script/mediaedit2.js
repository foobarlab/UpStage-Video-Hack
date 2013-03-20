/* media edit2 page -- uses jquery */

var datagrid;
var data = [];

function setupMediaEdit2(url_path) {
	
	// setup data grid
	
	setupDataGrid();
	
	// register button handlers
	
	$("#buttonUpdateView").click(function(e){
		$.ajax({type: "POST",
			url: url_path+"?ajax=update",
    		data: {
            	'filter_user': $("#filterUser").val(),
            	'filter_stage': $("#filterStage").val(),
            	'filter_type': $("#filterType").val(),
            	'filter_tags': $("#filterTags").val(),
            },
            success: function(response) {
            	if(response.status == 200) {
            		updateData(response.data);
            	} else {
            		// TODO handle error
            		alert("Error while retrieving data: status="+response.status+", timestamp="+ response.timestamp +", data="+response.data);
            	}
            	
            },
            error: function(XMLHttpRequest, textStatus, errorThrown){
                // TODO handle errors
            },
		});
	});

	$("#buttonResetView").click(function(e){
	    // TODO
	});
	
}

function testCallback(params) {
	alert("testCallback: params=" + params.toSource());
}

function setupDataGrid() {
	
	log.debug("setupDataGrid()");
	
	// TODO get data via ajax call
	
	var columns = [
	       {id: "name", name: "Name", field: "name"},
	       {id: "uploader", name: "Uploader", field: "uploader"},
	       {id: "type", name: "Type", field: "type"},
	       {id: "tags", name: "Tags", field: "tags"},
	       {id: "voice", name: "Voice", field: "voice"},
	       {id: "stages", name: "Stages", field: "stages"},
	       {id: "medium", name: "Medium", field: "medium"},
	       {id: "thumb", name: "Thumb", field: "thumb"},
	       {id: "media", name: "Media", field: "media"},
       ];

	var options = {
			enableCellNavigation: true,
			enableColumnReorder: false,
			editable: false,
		    asyncEditorLoading: false,
		    multiSelect: false,
		    forceFitColumns: true,
	};

	$(function () {
		
		datagrid = new Slick.Grid("#dataGrid", data, columns, options);
		datagrid.setSelectionModel(new Slick.RowSelectionModel());
		
		// add click event listener
		datagrid.onClick.subscribe(function(e,args) {
			var cell = datagrid.getCellFromEvent(e);
	        if(!cell) { return; }
			log.debug("click: cell.row="+cell.row);
	        parent.showDetails(data[cell.row]);
		});
		
	});
	
}

function updateData(update_data) {
	
	log.debug("updateData(): update_data="+update_data.toSource());
	
	//if (update_data != null) {
		data = update_data;
		datagrid.setData(update_data,true);
		datagrid.invalidate();
	//}
	
}

function showDetails(single_data) {
	
	log.debug("showDetails(): single_data="+single_data.toSource());
	
	alert("Showing details: single_data="+single_data.toSource());
	
}