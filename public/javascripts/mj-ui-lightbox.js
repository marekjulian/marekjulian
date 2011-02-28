/*

mj-ui-lightbox:

  Based upon http://particletree.com lightbox implementation, with enhancements.
  Inspired by the lightbox implementation found at http://www.huddletogether.com/projects/lightbox/
*/

if(typeof(Prototype) == "undefined") {
    throw "MJ_UI_LIGHTBOX requires Prototype to be loaded."; 
}

if(typeof(MJ_UI_LIGHTBOX) == "undefined") {
    var MJ_UI_LIGHTBOX = {
        detect : "",
        OS : "",
        browser : "",
        version : "",
        thestring : "",
        lightboxes : []
    };
}

MJ_UI_LIGHTBOX.detect = navigator.userAgent.toLowerCase();

MJ_UI_LIGHTBOX.checkIt = function (string) {
    place = this.detect.indexOf(string) + 1;
    this.thestring = string;
    return place;
};

//Browser detect script origionally created by Peter Paul Koch at http://www.quirksmode.org/
MJ_UI_LIGHTBOX.getBrowserInfo = function () {
    if (this.checkIt('konqueror')) {
        this.browser = "Konqueror";
        this.OS = "Linux";
    }
    else if (this.checkIt('safari')) this.browser = "Safari"
    else if (this.checkIt('omniweb')) this.browser = "OmniWeb"
    else if (this.checkIt('opera')) this.browser = "Opera"
    else if (this.checkIt('webtv')) this.browser = "WebTV";
    else if (this.checkIt('icab')) this.browser = "iCab"
    else if (this.checkIt('msie')) this.browser = "Internet Explorer"
    else if (!this.checkIt('compatible')) {
        this.browser = "Netscape Navigator"
        this.version = this.detect.charAt(8);
    }
    else this.browser = "An unknown browser";

    if (!this.version) this.version = this.detect.charAt(place + this.thestring.length);

    if (!this.OS) {
        if (this.checkIt('linux')) this.OS = "Linux";
        else if (this.checkIt('x11')) this.OS = "Unix";
        else if (this.checkIt('mac')) this.OS = "Mac"
        else if (this.checkIt('win')) this.OS = "Windows"
        else this.OS = "an unknown operating system";
    }
};

MJ_UI_LIGHTBOX.lightbox = Class.create();

MJ_UI_LIGHTBOX.lightbox.prototype = {

    yPos : 0,
    xPos : 0,

    initialize: function(ctrl) {
        MJ_UI_LIGHTBOX.lightboxes.push(this);
        this.ctrl = ctrl;
        this.content = ctrl.href;
        Event.observe(ctrl, 'click', this.activate.bindAsEventListener(this), false);
        Event.observe(ctrl, 'lb:activate', this.activate.bindAsEventListener(this), false);
        Event.observe(ctrl, 'lb:setContent', this.setContent.bindAsEventListener(this), false);
        ctrl.onclick = function(){return false;};
    },

    // Turn everything on - mainly the IE fixes
    activate: function(){
                alert("lightbox.activate!");
		if (MJ_UI_LIGHTBOX.browser == 'Internet Explorer'){
			this.getScroll();
			this.prepareIE('100%', 'hidden');
			this.setScroll(0,0);
			this.hideSelects('hidden');
		}
		this.displayLightbox("block");
    },
	
    // Ie requires height to 100% and overflow hidden or else you can scroll down past the lightbox
    prepareIE: function(height, overflow){
		bod = document.getElementsByTagName('body')[0];
		bod.style.height = height;
		bod.style.overflow = overflow;
  
		htm = document.getElementsByTagName('html')[0];
		htm.style.height = height;
		htm.style.overflow = overflow; 
    },
	
    // In IE, select elements hover on top of the lightbox
    hideSelects: function(visibility){
		selects = document.getElementsByTagName('select');
		for(i = 0; i < selects.length; i++) {
			selects[i].style.visibility = visibility;
		}
    },
	
    // Taken from lightbox implementation found at http://www.huddletogether.com/projects/lightbox/
    getScroll: function(){
		if (self.pageYOffset) {
			this.yPos = self.pageYOffset;
		} else if (document.documentElement && document.documentElement.scrollTop){
			this.yPos = document.documentElement.scrollTop; 
		} else if (document.body) {
			this.yPos = document.body.scrollTop;
		}
    },
	
    setScroll: function(x, y){
		window.scrollTo(x, y); 
    },
	
    displayLightbox: function(display){
		$('overlay').style.display = display;
		$('lightbox').style.display = display;
		if(display != 'none') this.loadInfo();
    },
	
    // Begin Ajax request based off of the href of the clicked linked
    loadInfo: function() {
		var myAjax = new Ajax.Request(
                    this.content,
                    {method: 'post', parameters: "", onComplete: this.processInfo.bindAsEventListener(this)}
		);
    },
	
    // Display Ajax response
    processInfo: function(response){
		info = "<div id='lbContent'>" + response.responseText + "</div>";
		new Insertion.Before($('lbLoadMessage'), info)
		$('lightbox').className = "done";	
		this.actions();			
    },
	
    // Search through new links within the lightbox, and attach click event
    actions: function(){
		lbActions = document.getElementsByClassName('lbAction');

		for(i = 0; i < lbActions.length; i++) {
			Event.observe(lbActions[i], 'click', this[lbActions[i].rel].bindAsEventListener(this), false);
                        if ( lbActions[i].rel == "deactivate" ) {
                            Event.observe(lbActions[i], 'lb:deactivate', this[lbActions[i].rel].bindAsEventListener(this), false);
                        }
			lbActions[i].onclick = function(){return false;};
		}

    },

    setContent: function(e) {
            this.content = e.memo.content
    },

    // Example of creating your own functionality once lightbox is initiated
    insert: function(e){
	   link = Event.element(e).parentNode;
	   Element.remove($('lbContent'));
	 
	   var myAjax = new Ajax.Request(
			  link.href,
			  {method: 'post', parameters: "", onComplete: this.processInfo.bindAsEventListener(this)}
	   );
	 
    },

    // Example of creating your own functionality once lightbox is initiated
    deactivate: function(){
		Element.remove($('lbContent'));
		
		if (MJ_UI_LIGHTBOX.browser == "Internet Explorer"){
			this.setScroll(0,this.yPos);
			this.prepareIE("auto", "auto");
			this.hideSelects("visible");
		}
		
		this.displayLightbox("none");
    },

    disable: function() {
        Event.stopObserving(this.ctrl, 'click');
        Event.stopObserving(this.ctrl, 'lb:activate');
        Event.stopObserving(this.ctrl, 'lb:deactivate');
        Event.stopObserving(this.ctrl, 'lb:setContent');
    }
}

// Onload, make all links that need to trigger a lightbox active
MJ_UI_LIGHTBOX.initializeOnLoad = function (){
    this.addLightboxMarkup();
    lbox = document.getElementsByClassName('lbOn');
    for(i = 0; i < lbox.length; i++) {
        newLightbox = new MJ_UI_LIGHTBOX.lightbox(lbox[i]);
    }
};

// When elements change, ie due to AJAX calls, just create all new lightboxes, but disabling the old ones.
MJ_UI_LIGHTBOX.reInitialize = function (){
    for(i = 0; i < this.lightboxes.length; i++) {
        this.lightboxes[i].disable()
    }
    this.lightboxes = []
    lbox = document.getElementsByClassName('lbOn');
    for(i = 0; i < lbox.length; i++) {
        newLightbox = new MJ_UI_LIGHTBOX.lightbox(lbox[i]);
    }
};

// Add in markup necessary to make this work. Basically two divs:
// Overlay holds the shadow
// Lightbox is the centered square that the content is put into.
MJ_UI_LIGHTBOX.addLightboxMarkup = function () {
    bod        = document.getElementsByTagName('body')[0];
    overlay    = document.createElement('div');
    overlay.id = 'overlay';
    lb         = document.createElement('div');
    lb.id      = 'lightbox';
    lb.className = 'loading';
    lb.innerHTML = '<div id="lbLoadMessage">' +
                   '<p>Loading</p>' +
                   '</div>';
    bod.appendChild(overlay);
    bod.appendChild(lb);
};

Event.observe(window, 'load', MJ_UI_LIGHTBOX.initializeOnLoad.bind(MJ_UI_LIGHTBOX), false);
Event.observe(window, 'load', MJ_UI_LIGHTBOX.getBrowserInfo.bind(MJ_UI_LIGHTBOX), false);
Event.observe(window, 'unload', Event.unloadCache, false);
