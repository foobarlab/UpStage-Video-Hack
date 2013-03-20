/* media edit2 page -- uses jquery */

function setupMediaEdit2(url_path) {
	
	// register button handlers
	
	$("#buttonUpdateView").click(function(e){
		$.ajax({type: "POST",
			url: url_path+"?ajax=update",
    		data: {
            	'user': $("#selectUser").val(),
            	'stage': $("#selectStage").val(),
            	'tags': $("#searchTagsField").val(),
            },
            success: function(response) {
            	alert("result:" + response);             
            },
            error: function(XMLHttpRequest, textStatus, errorThrown){
                // TODO handle errors
            },
		});
	});

	$("#buttonResetView").click(function(e){
	    // TODO
	});
	
	
	// setup data grid
	
	setupDataGrid();
	
}

function testCallback(params) {
	alert("testCallback: params=" + params);
}

function setupDataGrid() {
	
	log.debug("setupDataGrid()");
	
	var grid;
	var columns = [
	       {id: "name", name: "Name", field: "name"},
	       {id: "uploader", name: "Uploader", field: "uploader"},
	       {id: "typename", name: "Typename", field: "typename"},
	       {id: "tags", name: "Tags", field: "tags"},
	       {id: "voice", name: "Voice", field: "voice"},
	       {id: "stages", name: "Stages", field: "stages"},
	       {id: "medium", name: "Medium", field: "medium"},
	       {id: "thumb", name: "Thumb", field: "thumb"},
	       {id: "media", name: "Media", field: "media"},
       ];

	var options = {
			enableCellNavigation: true,
			enableColumnReorder: false
	};

	// gather data
	
	$(function () {
		var data = [];
		
		for (var i = 0; i < 50000; i++) {
			data[i] = {
					name: "dummy " + i,
					uploader: "admin",
					typename: "avatar",
					tags: "",
					voice: "default",
					stages: "test",
					medium: "stream",
					thumb: "/media/thumb/megaphone.jpg",
					media: "megaphone.swf",
			};
		}
		
		grid = new Slick.Grid("#dataGrid", data, columns, options);
	});
	
}

function updateDataGrid() {
	
	log.debug("updateDataGrid()");
	
}