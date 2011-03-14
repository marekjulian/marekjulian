/*
    Keeps track of any state for the content of various tabs:
        - collection instances : added, removed, and deleted images
        - portfolio collection instances : added, removed and deleted image show views.
 */

if(typeof(Prototype) == "undefined") {
    throw "cm/organizer requires Prototype to be loaded."; 
}

if(typeof(CM_ORGANIZER) == "undefined") {
    var CM_ORGANIZER = { };
}

CM_ORGANIZER.PreviewControl = Class.create( { 

    initialize : function() {
        // alert("CM_ORGANIZER.PreviewControl.initialize...");
        this.tabLinkToPreviewElem = $H({});
        this.activePreview = null;
        // alert("CM_ORGANIZER.PreviewControl.initialize - completed!");
    },

    addPreview : function ( tabLink, previewId ) {
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
    }

} );
