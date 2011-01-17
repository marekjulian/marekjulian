if(typeof(Prototype) == "undefined") {
    throw "MJ_UI requires Prototype to be loaded."; 
}

if(typeof(MJ_UI) == "undefined") {
    var MJ_UI = {};
}

MJ_UI.Tabs = Class.create( {

    initialize: function(tab_list_container,options){
        if(!$(tab_list_container)) {
            throw "MJ_UI.Tabs could not find the element: " + tab_list_container; }
        this.activeContainer = false;
        this.activeLink = false;
        this.containers = $H({});
        this.links = $A([]);
        MJ_UI.Tabs.instances.push(this);
        this.options = {
            linkSelector: 'li a',
            inactiveClassName: 'tab-inactive-link',
            activeClassName: 'tab-active-link',
            showFunction: Element.show,
            hideFunction: Element.hide,
            closeTabFunction: Element.remove,
            closeContainerFunction: Element.remove
        };
	Object.extend( this.options, options || {} );
        $(tab_list_container).select(this.options.linkSelector).findAll(function(link){
            return (/^#/).test((Prototype.Browser.WebKit ? decodeURIComponent(link.href) : link.href).replace(window.location.href.split('#')[0],''));
        }).each(function(link){
            this.addTab(link);
        }.bind(this));
        this.containers.values().each(Element.hide);
        this.setActiveTab(this.links.first());
    },

    addTab : function( link ) {
        this.links.push(link);
        link.key = link.getAttribute('href').replace(window.location.href.split('#')[0],'').split('#').last().replace(/#/,'');
        var container = $(link.key);
        if(!container) {
            throw "MJ_UI.Tabs: #" + link.key + " was not found on the page."; }
        this.containers.set(link.key,container);
        link[this.options.hover ? 'onmouseover' : 'onclick'] = function(link){
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
