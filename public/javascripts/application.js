// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function removeField(element, item) {
    element.up(item).remove();
}

//
//  To count the number of variants that have been added.
//  For cm/images/_new_image_form_iv.
//
var CmNewImageForm = {
    num_image_variants : 0,

    setNumImageVariants: function( v ) {
        this.num_image_variants = v;
        return this.num_image_variants;
    },

    addImageVariant: function() {
        this.num_image_variants = this.num_image_variants + 1;
        return this.num_image_variants;
    },

    numImageVariants: function() {
        return this.num_image_variants;
    },

    imageVariantIndex: function() {
        return this.num_image_variants - 1;
    }
}

//
//  To show/hide attribute check boxes.
//  For cm/images/_new_image_form_iv.
//
function nifShowHideCheckBoxes( selElem, checkBoxesElem, propModeElem ) {
    var value = selElem.options[selElem.selectedIndex].value
    alert( selElem.parentNode.parentNode.nextElementSibling.nodeName + ", " + selElem.parentNode.parentNode.nextElementSibling.attributes['class'].value + ", " + propModeElem.attributes['class'].value )
    if ( value == "You tell us..." ) {
        checkBoxesElem.show()
        propModeElem.value = 'user'
    }
    else {
        checkBoxesElem.hide()
        propModeElem.value = 'auto'
    }
}
