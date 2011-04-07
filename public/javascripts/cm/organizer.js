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
        if ( tabType == 'collection' ) {
            var newControl = new CM_ORGANIZER.WorkspaceCollectionTabInstanceControl( tabId, arguments[2], arguments[3] );

            this.tabIdToTabInstanceControl.set( tabId, newControl );
            // alert("CM_ORGANIZER.WorkspaceControl.addTab - done");
            return newControl;
        }
        else if ( tabType == 'collection-image' ) {
            var newControl = new CM_ORGANIZER.WorkspaceCollectionImageTabInstanceControl( tabId, arguments[2], arguments[3], arguments[4] );

            this.tabIdToTabInstanceControl.set( tabId, newControl );
            // alert("CM_ORGANIZER.WorkspaceControl.addTab - done");
            return newControl;
        }
        else if ( tabType == 'portfolio-collection' ) {
            var newControl = new CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl( tabId, arguments[2], arguments[3] );

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

CM_ORGANIZER.WorkspaceCollectionTabInstanceControl = Class.create( {

    initialize : function( tabId, collectionId, addImageUrl ) {
        this.tabType = 'collection';
        this.tabId = tabId;
        this.collectionId = collectionId;
        this.addImageUrl = addImageUrl;
        this.imageAreaContainerId = "organizer-workspace-body-collection-image-instance-list-" + tabId + "-" + collectionId
        this.draggables = $H({});
        this.droppables = $A();
        this.changes = $A();
    },

    droppedPreviewToWorkspace : function( previewImageLi ) {
        // alert("CM_ORGANIZER.WorkspaceCollectionTabInstanceControl.droppedPreviewToWorkspace - starting...");
        previewElementId = previewImageLi.readAttribute('id');
        previewElementIdParts = previewElementId.split('-');
        imageId = previewElementIdParts.pop();

        var change = new CM_ORGANIZER.WorkspaceCollectionTabInstanceAddChange( imageId );
        this.changes.push( change );

        //
        // Add a new workspace image.
        //
        reqUrl = this.addImageUrl + "&image_id=" + imageId + "&image_area_container_id=" + this.imageAreaContainerId
        // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to request image content, url = " + reqUrl);
        var req = new Ajax.Request( reqUrl,
                                    { method : 'get' } );

        var formId = "organizer-workspace-body-form-" + this.tabId + "-" + this.collectionId
        var formSaveId = formId + "-save";
        var enableClass = "organizer-form-enabled-button";
        var disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    addDraggable : function( draggable, draggableId ) {
        this.draggables.set( draggableId, draggable );
    },

    addDroppable : function( droppableId ) {
        this.droppables.push( droppableId );
    },

    save : function( formId, saveUrl ) {
        alert("CM_ORGANIZER.WorkspaceCollectionTabInstanceControl.save - formId = " + formId + ", saveUrl = " + saveUrl );

        var formData = $( formId ).serialize( true );

        formData[ 'collection_id' ] = this.collectionId;
        formData[ 'changes' ] = $A();

        this.changes.each( function( change ) { formData['changes'].push( { change_type : 'add',
                                                                            image_id : change.imageId } ); } );
        jsonPayload = Object.toJSON( formData );

        var self = this;

        var req = new Ajax.Request( saveUrl,
                                    { method : 'post',
                                      contentType : 'application/json',
                                      parameters : { format : 'json' },
                                      postBody : jsonPayload,
                                      onSuccess : function( response ) { self.changes = $A();
                                                                         var formSaveId = formId + '-save';
                                                                         var enableClass = "organizer-form-enabled-button";
                                                                         var disableClass = "organizer-form-disabled-button";
                                                                         $( formSaveId ).removeClassName( enableClass );
                                                                         $( formSaveId ).addClassName( enableClass ); }  
                                    } );
        return false;
    }

} );

CM_ORGANIZER.WorkspaceCollectionTabInstanceAddChange = Class.create( {

    initialize : function( imageId ) {
        // alert("CM_ORGANIZER.WorkspaceCollectionTabInstanceAddChange - " + imageId);
        this.imageId = imageId;
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

        var change = new CM_ORGANIZER.WorkspaceCollectionImageTabImageVariantChange( imageVariantId, fromImageId, this.imageId );
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

        var formId = "organizer-workspace-body-form-" + this.tabId + "-" + this.collectionId + "-" + this.imageId;
        var formSaveId = formId + "-save";
        var enableClass = "organizer-form-enabled-button";
        var disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    addDraggable : function( draggable, draggableId ) {
        this.draggables.set( draggableId, draggable );
    },

    addDroppable : function( droppableId ) {
        this.droppables.push( droppableId );
    },

    save : function( formId, saveUrl ) {
        // alert("CM_ORGANIZER.TabInstanceControl.save - formId = " + formId + ", saveUrl = " + saveUrl );
        var formData = $( formId ).serialize( true );
        // alert("CM_ORGANIZER.TabInstanceControl.save - type of formData = " + typeof(formData) );
        formData[ 'collection_id' ] = this.collectionId;
        formData[ 'image_id' ] = this.imageId;
        formData[ 'changes' ] = $A();
        this.changes.each( function( change ) { formData['changes'].push( { image_variant_id : change.imageVariantId,
                                                                            from_image_id : change.fromImageId,
                                                                            to_image_id : change.toImageId } ); } );
        jsonPayload = Object.toJSON( formData );

        var self = this;

        var req = new Ajax.Request( saveUrl,
                                    { method : 'post',
                                      contentType : 'application/json',
                                      parameters : { format : 'json' },
                                      postBody : jsonPayload,
                                      onSuccess : function( response ) { self.changes = $A();
                                                                         var formSaveId = formId + '-save';
                                                                         var enableClass = "organizer-form-enabled-button";
                                                                         var disableClass = "organizer-form-disabled-button";
                                                                         $( formSaveId ).removeClassName( enableClass );
                                                                         $( formSaveId ).addClassName( enableClass ); }  
                                    } );
        return false;
    },

    deleteTab : function() {
        alert("CM_ORGANIZER.TabInstanceControl.deleteTab - ...");
    }
    
} );

CM_ORGANIZER.WorkspaceCollectionImageTabImageVariantChange = Class.create( {

    initialize : function( imageVariantId, fromImageId, toImageId ) {
        // alert("CM_ORGANIZER.WorkspaceCollectionImageTabImageVariantChange - " + imageVariantId + ", " + fromImageId + ", " + toImageId);
        this.imageVariantId = imageVariantId;
        this.fromImageId = fromImageId;
        this.toImageId = toImageId;
    }

} );

CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl = Class.create( {

    initialize : function( tabId, portfolioCollectionId, addImageShowViewUrl ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.initialize - tabId = " + tabId + ", portfolioCollectionId = " + portfolioCollectionId + ", addImageShowViewUrl = " + addImageShowViewUrl );
        this.tabType = 'portfolio-collection';
        this.tabId = tabId;
        this.portfolioCollectionId = portfolioCollectionId;
        this.addImageShowViewUrl = addImageShowViewUrl;
        this.imageAreaContainerId = "organizer-workspace-body-portfolio-collection-instance-list-" + tabId + "-" + portfolioCollectionId;
        this.draggables = $H({});
        this.droppables = $A();
        this.changes = $A();
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.initialize - end.");
    },

    droppedPreviewToWorkspace : function( previewLi ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedPreviewToWorkspace - starting...");

        previewElementId = previewLi.readAttribute('id');
        previewElementIdParts = previewElementId.split('-');
        imageId = previewElementIdParts.pop();

        //
        //  Delete the droppable, and also its previewLi.
        //
        var draggable = CM_ORGANIZER.previewControl.destroyDraggable( this.tabId, previewElementId );
        // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to remove preview element with ID = " + previewElementId );
        $( previewElementId ).remove();

        var change = new CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceAddChange( imageId );
        this.changes.push( change );

        //
        // Add a new workspace image show view.
        //
        reqUrl = this.addImageShowViewUrl + "&image_id=" + imageId + "&image_area_container_id=" + this.imageAreaContainerId;
        // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to request image content, url = " + reqUrl);
        var req = new Ajax.Request( reqUrl,
                                    { method : 'get' } );

        var formId = "organizer-workspace-body-form-" + this.tabId + "-" + this.portfolioCollectionId;
        var formSaveId = formId + "-save";
        var enableClass = "organizer-form-enabled-button";
        var disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    addDraggable : function( draggable, draggableId ) {
        this.draggables.set( draggableId, draggable );
    },

    addDroppable : function( droppableId ) {
        this.droppables.push( droppableId );
    },

    save : function( formId, saveUrl ) {
        alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.save - formId = " + formId + ", saveUrl = " + saveUrl );

        var formData = $( formId ).serialize( true );

        formData[ 'portfolio_collection_id' ] = this.portfolioCollectionId;
        formData[ 'changes' ] = $A();
        this.changes.each( function( change ) { formData['changes'].push( { change_type : 'add',
                                                                            image_id : change.imageId } ); } );

        jsonPayload = Object.toJSON( formData );

        var self = this;

        var req = new Ajax.Request( saveUrl,
                                    { method : 'post',
                                      contentType : 'application/json',
                                      parameters : { format : 'json' },
                                      postBody : jsonPayload,
                                      onSuccess : function( response ) { self.changes = $A();
                                                                         var formSaveId = formId + '-save';
                                                                         var enableClass = "organizer-form-enabled-button";
                                                                         var disableClass = "organizer-form-disabled-button";
                                                                         $( formSaveId ).removeClassName( enableClass );
                                                                         $( formSaveId ).addClassName( enableClass ); }  
                                    } );

        return false;
    }

} );

CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceAddChange = Class.create( {

    initialize : function( imageId ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceAddChange - adding image = " + imageId);
        this.imageId = imageId;
    }

} );
