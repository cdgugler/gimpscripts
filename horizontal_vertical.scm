;copy current layer
(define (copy-layer image)
  (gimp-image-insert-layer image 
                           (car (gimp-layer-copy (car (gimp-image-get-active-layer image)) 0))
                           0 
                           0))

;takes image and mirrors horizontally or vertically per orientation param
(define (mirror-flip image originalWidth originalHeight orientation)
 (if (= orientation ORIENTATION-VERTICAL)
    (begin
     (define transformLoc originalHeight)
     (define originalHeight (* 2 originalHeight)))
 (define transformLoc originalWidth))

 (copy-layer image)
 ; double original width for both operations
 (gimp-image-resize image (* 2 originalWidth) originalHeight 0 0)
 (gimp-item-transform-flip-simple (car (gimp-image-get-active-layer image)) orientation FALSE transformLoc)
 (gimp-image-flatten image)
)

(define (script-fu-horizontal-vertical image
                                       drawable)
 (let*
  (
   (imageWidth (car (gimp-image-width image)))
   (imageHeight (car (gimp-image-height image)))
  )
  (mirror-flip image imageWidth imageHeight ORIENTATION-HORIZONTAL)
  (mirror-flip image imageWidth imageHeight ORIENTATION-VERTICAL)
  (gimp-displays-flush)
 )
)

(script-fu-register
 "script-fu-horizontal-vertical"
 "Horizontal Vertical Mirror"
 "Mirrors horizontal then vertical to create tileable asset"
 "Cory Gugler"
 "Do what you want"
 "10-06-2013"
 "RGB* GRAY*"
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 )
(script-fu-menu-register "script-fu-horizontal-vertical" "<Image>/Image/Transform")
