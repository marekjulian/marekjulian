var Image {
    newImageVariantAddId: function() {
        if (! this.nextNewImageVariantAddNum) {
            this.nextNewImageVariantAddSeq = 0;
        }
        else {
            this.nextNewImageVariantAddSeq += 1;
        }
        return "ImageVariantAddID_" + this.nextNewImageVariantAddSeq.toString();
    }
}
