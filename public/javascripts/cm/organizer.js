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
        else if ( tabType == 'portfolio' ) {
            var newControl = new CM_ORGANIZER.WorkspacePortfolioTabInstanceControl( tabId, arguments[2], arguments[3] );

            this.tabIdToTabInstanceControl.set( tabId, newControl );
            // alert("CM_ORGANIZER.WorkspaceControl.addTab - done");
            return newControl;
        }
        else if ( tabType == 'portfolio-collection' ) {
            var newControl = new CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl( tabId, arguments[2], arguments[3], arguments[4], arguments[5], arguments[6] );

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
        // alert("CM_ORGANIZER.WorkspaceCollectionTabInstanceControl.save - formId = " + formId + ", saveUrl = " + saveUrl );

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

CM_ORGANIZER.WorkspacePortfolioTabInstanceControl = Class.create( {

    initialize : function( tabId, portfolioId, replaceDefaultShowViewUrl ) {
        this.tabType = 'portfolio';
        this.tabId = tabId;
        this.portfolioId = portfolioId;
        this.replaceDefaultShowViewUrl = replaceDefaultShowViewUrl;
        var formId = "organizer-workspace-body-form-" + this.tabId + "-" + this.portfolioId;
        this.defaultShowViewContainerId = formId + "-show-view"
        this.defaultPortfolioCollectionId = null;
    },

    droppedWorkspaceToFormDefaultShowView : function( workspaceLi ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioTabInstanceControl.droppedWorkspaceToFormDefaultShowView - ...");
        wElemId = workspaceLi.readAttribute('id');
        wElemIdParts = wElemId.split('-');
        this.defaultPortfolioCollectionId = wElemIdParts.pop();

        //
        // Replace the default image for the portfolio.
        //
        reqUrl = this.replaceDefaultShowViewUrl + "&portfolio_collection_id=" + this.defaultPortfolioCollectionId + "&image_area_container_id=" + this.defaultShowViewContainerId;
        // alert("CM_ORGANIZER.TabInstanceControl.droppedWorkspaceToFormDefaultShowView - about to request default show view image, url = " + reqUrl);
        var req = new Ajax.Request( reqUrl,
                                    { method : 'get' } );

        var formId = "organizer-workspace-body-form-" + this.tabId + "-" + this.portfolioId;
        var formSaveId = formId + "-save";
        var enableClass = "organizer-form-enabled-button";
        var disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    save : function( formId, saveUrl ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioTabInstanceControl.save - ...");

        var formData = $( formId ).serialize( true );

        formData[ 'portfolio_id' ] = this.portfolioId
        if ( this.defaultPortfolioCollectionId ) {
            formData[ 'default_portfolio_collection_id' ] = this.defaultPortfolioCollectionId;
        }

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

CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl = Class.create( {

    initialize : function( tabId, portfolioCollectionId, addPreviewImageUrl, replaceDefaultShowViewUrl, addImageUrl, addImageShowViewUrl ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.initialize - tabId = " + tabId + ", portfolioCollectionId = " + portfolioCollectionId + ", addImageShowViewUrl = " + addImageShowViewUrl );
        this.tabType = 'portfolio-collection';
        this.tabId = tabId;
        this.portfolioCollectionId = portfolioCollectionId;
        this.addPreviewImageUrl = addPreviewImageUrl;
        this.replaceDefaultShowViewUrl = replaceDefaultShowViewUrl;
        this.addImageUrl = addImageUrl;
        this.addImageShowViewUrl = addImageShowViewUrl;
        this.imageAreaContainerId = "organizer-workspace-body-portfolio-collection-instance-list-" + tabId + "-" + portfolioCollectionId;
        this.draggables = $H({});
        this.droppables = $A();
        this.lastChangeId = -1;
        this.changes = $A();
        this.formId = "organizer-workspace-body-form-" + this.tabId + "-" + this.portfolioCollectionId;
        this.defaultShowViewContainerId = this.formId + "-show-view"
        this.newDefaultShowView = null;
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.initialize - end.");
    },

    droppedWorkspaceToFormDefaultShowView : function( workspaceLi ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedWorkspaceToFormDefaultShowView - ...");
        wElemId = workspaceLi.readAttribute('id');
        wElemIdParts = wElemId.split('-');

        if (( wElemIdParts[2] === 'added' ) && ( wElemIdParts[3] === 'img' )) {
            //
            // Taking an image which has been dragged from the preview to the workspace, and setting it as the new default.
            //
            changeId = wElemIdParts[6];
            imageId = wElemIdParts[7];
            // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedWorkspaceToFormDefaultShowView - received added image, change id = " + changeId + ", image id = " + imageId);
            this.newDefaultShowView = new CM_ORGANIZER.WorkspacePortfolioCollectionAddImageRef( imageId, changeId );
            reqUrl = this.replaceDefaultShowViewUrl + "&image_id=" + imageId + "&image_area_container_id=" + this.defaultShowViewContainerId;
        }
        else {
            imageShowViewId = wElemIdParts[8];
            // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedWorkspaceToFormDefaultShowView - received image show view, id = " + imageShowViewId + "!");
            this.newDefaultShowView = new CM_ORGANIZER.WorkspacePortfolioCollectionImageShowViewRef( imageShowViewId );
            reqUrl = this.replaceDefaultShowViewUrl + "&image_show_view_id=" + imageShowViewId + "&image_area_container_id=" + this.defaultShowViewContainerId;
        }

        //
        // Replace the default image for the portfolio.
        //

        // alert("CM_ORGANIZER.TabInstanceControl.droppedWorkspaceToFormDefaultShowView - about to request default show view image, url = " + reqUrl);
        var req = new Ajax.Request( reqUrl,
                                    { method : 'get' } );

        var formSaveId = this.formId + "-save";
        var enableClass = "organizer-form-enabled-button";
        var disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    droppedPreviewToWorkspace : function( previewLi ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedPreviewToWorkspace - starting...");

        pElemId = previewLi.readAttribute('id');
        pElemIdParts = pElemId.split('-');
        imageId = pElemIdParts.pop();

        removedIndex = this.removedImageChangeIndex( imageId );
        if ( removedIndex !== -1 ) {
            // alert('CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedPreviewToWorkspace - dropped previoiusly removed image...');
            //
            // Remove the change...
            //
            change = this.changes[removedIndex];
            imageShowViewId = change.imageShowViewId;
            this.changes.splice( removedIndex, 1);
            var draggable = CM_ORGANIZER.previewControl.destroyDraggable( this.tabId, pElemId );
            //
            //  Remove the preview image.
            //
            // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to remove preview element with ID = " + previewElemId );
            $( pElemId ).remove();            
            //
            // Redisplay the original image_show_view in the workspace.
            //
            reqUrl = this.addImageShowViewUrl + "&image_show_view_id=" + imageShowViewId + "&image_area_container_id=" + this.imageAreaContainerId + "&form_id=" + this.formId;
        }
        else {
            // alert('CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedPreviewToWorkspace - adding image to portfolio collection...');
            this.lastChangeId = this.lastChangeId + 1;
            change = new CM_ORGANIZER.WorkspacePortfolioCollectionAddImageChange( imageId, this.lastChangeId );
            this.changes.push( change );
            //
            //  Delete the draggable, and also its previewLi.
            //
            var draggable = CM_ORGANIZER.previewControl.destroyDraggable( this.tabId, pElemId );
            //
            //  Remove the preview image.
            //
            // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to remove preview element with ID = " + previewElemId );
            $( pElemId ).remove();
            //
            // Add a new workspace image show view.
            //
            reqUrl = this.addImageUrl + "&image_id=" + imageId + "&image_area_container_id=" + this.imageAreaContainerId + "&change_id=" + change.changeId + "&form_id=" + this.formId;
        }

        // alert("CM_ORGANIZER.TabInstanceControl.droppedPreviewToWorkspace - about to request image content, url = " + reqUrl);
        var req = new Ajax.Request( reqUrl,
                                    { method : 'get' } );

        var formSaveId = this.formId + "-save";
        var enableClass = "organizer-form-enabled-button";
        var disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    droppedWorkspaceToPreview : function( workspaceLi ) {
        wElemId = workspaceLi.readAttribute('id');
        wElemIdParts = wElemId.split('-');
        imageId = wElemIdParts.pop();

        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedWorkspaceToPreview - workspace image id = " + imageId );

        addedIndex = this.addedImageChangeIndex( imageId );
        if ( addedIndex !== -1 ) {
            // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedWorkspaceToPreview - removing a previously added image, addedIndex = " + addedIndex);
            //
            // 1. remove AddImageChange(image) from this.changes
            //
            change = this.changes[addedIndex];
            // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedWorkspaceToPreview - doing splice with addedIndex = " + addedIndex);
            this.changes.splice( addedIndex, 1);
        }
        else {
            // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.droppedWorkspaceToPreview - removing an existing image show view with image id = " + imageId + "!");
            //
            // 1. add RemoveImageShowViewChange(image_show_view) to this.changes
            //
            this.lastChangeId = this.lastChangeId + 1;
            imageShowViewId = wElemIdParts.pop();
            change = new CM_ORGANIZER.WorkspacePortfolioCollectionRemoveImageShowViewChange( imageShowViewId, imageId, this.lastChangeId );
            this.changes.push( change );
        }
        //
        // 2. remove element from workspace
        //   - also delete and recreate sortables
        //
        $( wElemId ).remove();
        this.createSortable();
        //
        // 3. add image to preview
        //
        reqUrl = this.addPreviewImageUrl + "&image_id=" + imageId;
        var req = new Ajax.Request( reqUrl, { method: 'get' } );
        //
        // 4. if (image corresponds to this.newDefaultShowView) { this.newDefaultShowView = null; }
        //
        if ( (this.newDefaultShowView != null) && (this.newDefaultShowView.imageId === imageId) ) {
            this.newDefaultShowView = null;
        }

        var formSaveId = this.formId + "-save";
        var enableClass = "organizer-form-enabled-button";
        var disableClass = "organizer-form-disabled-button";
        $( formSaveId ).removeClassName( disableClass );
        $( formSaveId ).addClassName( enableClass );
    },

    addDraggable : function( draggable, draggableId ) {
        this.draggables.set( draggableId, draggable );
    },

    addDroppable : function( droppableId ) {
        // alert("Adding droppable with  id = " + droppableId + "!");
        this.droppables.push( droppableId );
    },

    createSortable : function() {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.creatingSortable - about to create sortable, container id = " + this.imageAreaContainerId);
        var self = this;
        Sortable.create( this.imageAreaContainerId,
                         { handles: $$( '#' + this.imageAreaContainerId + ' img' ),
                           format: /^(.*)$/,
                           ghosting: false,
                           overlap: 'horizontal',
                           constraint: '',
                           onUpdate: function( container ) {
                               $( self.formId + "-save" ).removeClassName( 'organizer-form-disabled-button' );
                               $( self.formId + "-save" ).addClassName( 'organizer-form-enabled-button' );
                             }
                         } );
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.creatingSortable - created!");
    },

    save : function( formId, saveUrl ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.save - formId = " + formId + ", saveUrl = " + saveUrl );

        var formData = $( formId ).serialize( true );

        formData[ 'tab_id' ] = this.tabId;
        formData[ 'image_area_container_id' ] = this.imageAreaContainerId;
        formData[ 'portfolio_collection_id' ] = this.portfolioCollectionId;
        formData[ 'form_id' ] = formId;
        formData[ 'changes' ] = $A();
        this.changes.each( function( change ) { if ( change.changeType == 'add' ) {
                                                    formData['changes'].push( { change_type : 'add',
                                                                                change_id : change.changeId,
                                                                                image_id : change.imageId } );
                                                }
                                                else if ( change.changeType == 'remove' ) {
                                                    formData['changes'].push( { change_type : 'remove',
                                                                                change_id : change.changeId,
                                                                                image_show_view_id : change.imageShowViewId,
                                                                                image_id : change.imageId } );
                                                }
            } );
      
        formData[ 'sortables' ] = Sortable.serialize( this.imageAreaContainerId, { name: 'images' } );

        if ( this.newDefaultShowView !== null ) {
            if ( this.newDefaultShowView.type === 'imageShowView' ) {
                formData[ 'new_default_show_view' ] = { 'type' : 'image_show_view',
                                                        'image_show_view_id' : this.newDefaultShowView.imageShowViewId
                                                      };
            }
            else if ( this.newDefaultShowView.type === 'image' ) {
                // alert("Have new defualt show view, image id = " + this.newDefaultShowView.imageId);
                formData[ 'new_default_show_view' ] = { 'type' : 'image',
                                                        'image_id' : this.newDefaultShowView.imageId,
                                                        'change_id' : this.newDefaultShowView.changeId };
            }
        }

        jsonPayload = Object.toJSON( formData );

        var self = this;

        var req = new Ajax.Request( saveUrl,
                                    { method : 'post',
                                      contentType : 'application/json',
                                      parameters : { format : 'json' },
                                      postBody : jsonPayload,
                                      onSuccess : function( response ) { self.changes = $A();
                                                                         self.newDefaultShowView = null;
                                                                         var formSaveId = formId + '-save';


                                                                         var enableClass = "organizer-form-enabled-button";
                                                                         var disableClass = "organizer-form-disabled-button";
                                                                         $( formSaveId ).removeClassName( enableClass );
                                                                         $( formSaveId ).addClassName( disableClass );
                                                                         // alert('Save request completed, container id = ' + self.imageAreaContainerId);
                                                                        }
                                    } );

        return false;
    },

    addedImageChangeIndex : function( imageId ) {
        for (var index = 0, len = this.changes.length; index < len; ++index) {
            change = this.changes[index];
            if (( change.changeType === 'add' ) && (change.imageId === imageId)) {
                return index;
            }
        }
        return -1;
    },

    removedImageChangeIndex : function( imageId ) {
        for (var index = 0, len = this.changes.length; index < len; ++index) {
            change = this.changes[index];
            if (( change.changeType === 'remove' ) && (change.imageId === imageId)) {
                return index;
            }
        }
        return -1;
    },

    showChanges : function( imageId ) {
        for (var index = 0, len = this.changes.length; index < len; ++ index) {
            change = this.changes[index];
            // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceControl.showChanges - changeType = " + change.changeType + ", image id = " + change.imageId);
        }
    }

} );

CM_ORGANIZER.WorkspacePortfolioCollectionImageShowViewRef = Class.create( {

    initialize : function( id ) {
        this.type = 'imageShowView';
        this.imageShowViewId = id;
    }

});

CM_ORGANIZER.WorkspacePortfolioCollectionAddImageRef = Class.create( {

    initialize : function( id, changeId ) {
        this.type = 'image';
        this.imageId = id;
        this.changeId = changeId;
    }

});

CM_ORGANIZER.WorkspacePortfolioCollectionAddImageChange = Class.create( {

    initialize : function( id, changeId ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceAddChange - adding image = " + imageId);
        this.changeType = 'add';
        this.changeId = changeId;
        this.imageId = id;
    }

} );

CM_ORGANIZER.WorkspacePortfolioCollectionRemoveImageShowViewChange = Class.create( {

    initialize : function( id, imageId, changeId ) {
        // alert("CM_ORGANIZER.WorkspacePortfolioCollectionTabInstanceAddChange - adding image = " + imageId);
        this.changeType = 'remove';
        this.changeId = changeId;
        this.imageShowViewId = id;
        this.imageId = imageId;
    }

} );
