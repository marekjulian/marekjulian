if(typeof(Prototype) == "undefined") {
    throw "MJ_UI requires Prototype to be loaded."; 
}

if(typeof(MJ_UI) == "undefined") {
    var MJ_UI = {};
}

//
//  Tab: Properties of a tab. Preperties include:
//      id - A unique integer ID (NOT an html ID).
//      link - The DOM element which is the link associated with the TAB.
//      containerId - The HTML ID of the container that contains the body of the tab.
//
MJ_UI.Tab = Class.create( {

    initialize: function( id, link ) {
        // alert("MJ_UI.Tab.intialize...");
        this.id = id;
        this.link = link;
        this.containerId = link.getAttribute('href').replace(window.location.href.split('#')[0],'').split('#').last().replace(/#/,'');
        // alert("MJ_UI.Tab.intialize - completed!");
    }

} );

//
//  Tabs: A structure that keeps track of a set of tabs, and facilities:
//      - create all tabs initially,
//      - adding new tabs (addTab),
//      - closing tabs and thereby removing them (closeTab),
//      - making a tab active (setActiveTab).
//
//      Fields are:
//          activeLink: The link (DOM element) associated with the currently active tab.
//          activeContainer: The container (DOM element) associate with the body of the tab.
//          tabs: mapping of links (DOM elements) -> MJ_UI.Tab instances with properties of a specific tab.
//          links: array of current tab links (DOM elements).
//          containers: mapping of tab BODY ids (HTML ids) to tab cobody container elements.
//          nextTabId: Next availabe ID for a new tab.
//
MJ_UI.Tabs = Class.create( {

    initialize: function(tab_list_container,options){
        // alert("MJ_UI.Tabs.initialize...");
        if(!$(tab_list_container)) {
            throw "MJ_UI.Tabs could not find the element: " + tab_list_container; }
        this.activeContainer = false;
        this.activeLink = false;
        this.tabs = $H({});
        this.links = $A([]);
        this.containers = $H({});
        this.nextTabId = 1;
        MJ_UI.Tabs.instances.push(this);
        this.options = {
            linkSelector: 'li a',
            inactiveClassName: 'tab-inactive-link',
            activeClassName: 'tab-active-link',
            preShowCallback: null,
            showFunction: Element.show,
            hideFunction: Element.hide,
            closeTabFunction: Element.remove,
            closeContainerFunction: Element.remove,
            loadingId : null,
            onEvent : 'onclick'
        };
        Object.extend( this.options, options || {} );
        $(tab_list_container).select(this.options.linkSelector).findAll(function(link){
            return (/^#/).test((Prototype.Browser.WebKit ? decodeURIComponent(link.href) : link.href).replace(window.location.href.split('#')[0],''));
        }).each(function(link){
            this.addTab(link);
        }.bind(this));
        this.containers.values().each(Element.hide);
        this.setActiveTab(this.links.first());
        // alert("MJ_UI.Tabs.initialize - completed!");
    },

    showLoading : function( ) {
        if ( this.options.loadingId ) {
            if (this.activeContainer) {
                this.options.hideFunction(this.activeContainer);
            }
            $(this.options.loadingId).show();
        }
    },

    addTab : function( link ) {
        // alert("MJ_UI.Tabs.addTab - ...");
        tab = new MJ_UI.Tab( this.nextTabId, link );
        this.nextTabId = this.nextTabId + 1;
        this.links.push(link);
        this.tabs.set( link, tab );
        link.key = tab.containerId;
        var container = $(link.key);
        if(!container) {
            throw "MJ_UI.Tabs: #" + link.key + " was not found on the page."; }
        this.containers.set(link.key,container);
        link[this.options.onEvent] = function(link){
            if(window.event) {
                Event.stop(window.event); }
            this.setActiveTab(link);
            return false;
        }.bind(this,link);
        var closeTabElem = $(link.key + '-close');
        var tabElem = $(link.key + '-tab');
        if (closeTabElem && tabElem) {
            closeTabElem.onclick = function() { this.closeTab(link, tabElem); }.bind(this);
        };
    },

    closeTab : function( link, tabElem ) {
        remainingLinks = this.links.without( link );
        this.links.each( function( oldLink ) {
            if ( oldLink == link ) {
                this.tabs.unset( oldLink );
                this.options.closeContainerFunction( this.containers.get(oldLink.key) );
                this.containers.unset( oldLink.key );
                oldLink.removeClassName( this.options.activeClassName );
            }
        }.bind(this));
        this.links = remainingLinks;
        this.options.closeTabFunction( tabElem );
        this.setActiveTab( this.links.first() );
    },

    setActiveTab : function( link ) {
        // alert("mj-ui.Tabs.setActiveTab - for link: " + link);
        if(!link && typeof(link) == 'undefined') {
            return; 
        }
        if(this.activeContainer) {
            this.options.hideFunction(this.activeContainer);
        }
        this.links.each( function(item) {
            item.removeClassName(this.options.activeClassName);
            item.addClassName(this.options.inactiveClassName);
        }.bind(this));
        link.addClassName(this.options.activeClassName);
        this.activeContainer = this.containers.get(link.key);
        this.activeLink = link;
        // alert("mj-ui.Tabs.setActiveTab - checking for preShowCallback...");        
        if (this.options.preShowCallback) {
            // alert("mj-ui.Tabs.setActiveTab - About to call preShowCallback...");        
            this.options.preShowCallback( link );
            // alert("mj-ui.Tabs.setActiveTab - Called preShowCallback...");
        }
        if ( this.options.loadingId ) {
            $( this.options.loadingId ).hide();
        }
        this.options.showFunction(this.containers.get(link.key));
    },

    next : function() {
        this.links.each( function( link, i ) {
            if ( this.activeLink == link && this.links[i + 1] ) {
                this.setActiveTab( this.links[i + 1] );
                throw $break;
            }
        }.bind(this) );
    },

    previous : function() {
        this.links.each( function( link, i ) {
            if ( this.activeLink == link && this.links[i - 1] ) {
                this.setActiveTab( this.links[i - 1] );
                throw $break;
            }
        }.bind( this ) );
    },

    first : function() {
        this.setActiveTab(this.links.first());
    },

    last : function() {
        this.setActiveTab(this.links.last());
    },

    findByTabId: function(id){
        return MJ_UI.Tabs.instances.find(function(tab){
            return tab.links.find(function(link){
                return link.key == id;
            });
        });
    }
    
} );

Object.extend( MJ_UI.Tabs, {
    instances : [] });
