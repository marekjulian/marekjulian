/*
    Keeps track of any state for the content of various tabs:
        - collection instances : added, removed, and deleted images
        - portfolio collection instances : added, removed and deleted image show views.
 */

if(typeof(Prototype) == "undefined") {
    throw "cm/organizer requires Prototype to be loaded."; 
}

if(typeof(CM_ORGANIZER) == "undefined") {
    var CM_ORGANIZER = { previewControl : null,
                         workspaceControl : null,
                         newPreviewControl : function() {
                             this.previewControl = new this.PreviewControl();
                         },
                         newWorkspaceControl : function() {
                             this.workspaceControl = new this.WorkspaceControl();
                         }
     };
}

CM_ORGANIZER.PreviewControl = Class.create( { 

    initialize : function() {
        // alert("CM_ORGANIZER.PreviewControl.initialize...");
        this.tabLinkToPreviewElem = $H({});
        this.activePreview = null;
        this.draggables = $H({});
        // alert("CM_ORGANIZER.PreviewControl.initialize - completed!");
    },

    addPreview : function ( tabLink, previewId ) {
        // alert("CM_ORGANIZER.PreviewControl.addPreview - " + previewId);
        var previewElem = $(previewId);
        if (!previewElem) {
            throw "CM_ORGANIZER.PreviewControl.addPreview - element not found on page, element id == " + previewId + "!";
        }
        this.tabLinkToPreviewElem.set( tabLink, previewElem );
    },

    setActivePreview : function ( tabLink ) {
        // alert("CM_ORGANIZER.PreviewControl.setActivePreview - check for activePreview...");
        if (this.activePreview) {
            // alert("CM_ORGANIZER.PreviewControl.setActivePreview - activePreview found...");
            this.activePreview.hide();
            this.activePreview = null;
            // alert("CM_ORGANIZER.PreviewControl.setActivePreview - hid activePreview and set to null...");
        }
        this.activePreview = this.tabLinkToPreviewElem.get( tabLink );
        this.activePreview.show();
    },

    draggableId : function( tabId, draggableId ) {
        return tabId + " " + draggableId;
    },

    addDraggable : function( draggable, tabId, draggableId ) {
        k = this.draggableId( tabId, draggableId);
        // alert("CM_ORGANIZER.PreviewControl.addDraggable - tabId = " + tabId + ", draggableId = " + draggableId + ", k = " + k);
        this.draggables.set( k, draggable );
    },


    getDraggable : function( tabId, draggableId ) {
        k = this.draggableId( tabId, draggableId );
        // alert("CM_ORGANIZER.PreviewControl.getDraggable - key = " + k );
        return this.draggables.get( k );
    },

    destroyDraggable : function ( tabId, draggableId ) {
        // alert("CM_ORGANIZER.PreviewControl.destroyDraggable - ");
        this.getDraggable( tabId, draggableId ).destroy();
        this.draggables.unset( this.draggableId( tabId, draggableId ) );
    }

} );

CM_ORGANIZER.WorkspaceControl = Class.create( {

    initialize : function() {
        this.tabIdToTabInstanceControl = $H({});
    },

    addTab : function( tabId, tabType ) {
        // alert("CM_ORGANIZER.WorkspaceControl.addTab - tabId = " + tabId + ", " + tabType );
        if ( tabType == 'collection-image' ) {
            var newControl = new CM_ORGANIZER.WorkspaceCollectionImageTabInstanceControl( tabId, arguments[2], arguments[3], arguments[4] );

            this.tabIdToTabInstanceControl.set( tabId, newControl );
            // alert("CM_ORGANIZER.WorkspaceControl.addTab - done");
            return newControl;
        }
        return null;
    },

    getTabControl : function( tabId ) {
        return this.tabIdToTabInstanceControl.get( tabId );
    },

    addDraggable : function( draggable, tabId, draggableId ) {
        this.getTabControl( tabId ).addDraggable( draggable, draggableId );
    },

    addDroppable : function( tabId, droppableId ) {
        // alert("CM_ORGANIZER.WorkspaceControl.addDroppable - tabId = " + tabId + ", droppableId = " + droppableId );        
        tabControl = this.getTabControl( tabId );
        if ( tabControl ) {
            tabControl.addDroppable( droppableId );
        }
    },

    deleteTab : function( tabId ) {
        tabControl = this.getTabControl( tabId );
        if ( tabControl ) {
            tabControl.deleteTab();
        }
    }

} );

CM_ORGANIZER.WorkspaceCollectionImageTabInstanceControl = Class.create( {

    initialize : function( tabId, collectionId, imageId, addImageVariantUrl ) {
        // alert("CM_ORGANIZER.WorkspaceCollectioniImageInstanceControl.initialize - tabId = " + tabId + ", collectionId = " + collectionId + ", imageId = " + imageId + ", addImageVariantUrl = " + addImageVariantUrl );
        this.tabType = 'collection-image';
        this.tabId = tabId;
        this.collectionId = collectionId;
        this.imageId = imageId;
        this.addImageVariantUrl = addImageVariantUrl;
        this.draggables = $H({});
        this.droppables = $A();
        this.changes = $A();
        // alert("CM_ORGANIZER.WorkspaceCollectioniImageInstanceControl.initialize - end.");
    },

    droppedPreviewToWorkspace : function( previewLi ) {
        // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - starting...");
        previewElementId = previewLi.readAttribute('id');
        previewElementIdParts = previewElementId.split('-');
        imageVariantId = previewElementIdParts.pop();
        fromImageId = previewElementIdParts.pop();
        var change = new CM_ORGANIZER.WorkspaceCollectionImageTabAddImageVariantChange( imageVariantId, fromImageId, this.imageId );
        this.changes.push( change );
        //
        //  Delete the droppable, and also its previewLi.
        //
        var draggable = CM_ORGANIZER.previewControl.destroyDraggable( this.tabId, previewElementId );
        // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to remove preview element with ID = " + previewElementId );
        $( previewElementId ).remove();

        //
        // Add a new workspace image variant.
        //
        reqUrl = this.addImageVariantUrl + "&image_variant_id=" + imageVariantId
        // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to request image content, url = " + reqUrl);
        var req = new Ajax.Request( reqUrl,
                                    { method : 'get' } );

        formId = "organizer-workspace-body-form-" + this.tabId + "-" + this.collectionId + "-" + this.imageId;
        formSaveId = formId + "-save";
        enableClass = "organizer-form-enabled-button";
        disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    addDraggable : function( draggable, draggableId ) {
        this.draggables.set( draggableId, draggable );
    },

    addDroppable : function( droppableId ) {
        this.droppables.push( droppableId );
    },

    save : function() {
        alert("CM_ORGANIZER.TabInstanceControl.save - ...");
    },

    deleteTab : function() {
        alert("CM_ORGANIZER.TabInstanceControl.deleteTab - ...");
    }
    
} );

CM_ORGANIZER.WorkspaceCollectionImageTabAddImageVariantChange = Class.create( {

    initialize : function( imageVariantId, fromImageId, toImageId ) {
        // alert("CM_ORGANIZER.WorkspaceCollectionImageTabAddImageVariantChange - " + imageVariantId + ", " + fromImageId + ", " + toImageId);
        this.imageVariantId = imageVariantId;
        this.fromImageId = fromImageId;
        this.toImageId = toImageId;
    }

} );
