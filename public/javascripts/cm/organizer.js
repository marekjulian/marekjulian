/*
    Keeps track of any state for the content of various tabs:
        - collection instances : added, removed, and deleted images
        - portfolio collection instances : added, removed and deleted image show views.
 */

if(typeof(Prototype) == "undefined") {
    throw "cm/organizer requires Prototype to be loaded."; 
}

if(typeof(CM_ORGANIZER) == "undefined") {
    var CM_ORGANIZER = { collectionInstances : [],
                         portfolioCollectionInstances : [] };
}

CM_ORGANIZER.CollectionInstanceState = Class.create( {

        initialize : function ( id ) {
        }

    } );
