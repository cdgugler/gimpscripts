(define (mirror_flip image imageWidth newWidth imageHeight)
  ;copy current layer
  (gimp-image-insert-layer image 
                           (car (gimp-layer-copy (car (gimp-image-get-active-layer image))
                                                 0))
                           0 
                           0)
  ;resize image
  (gimp-image-resize image newWidth imageHeight 0 0)
  ;flip new layer horizontally by original width
  (gimp-item-transform-flip-simple (car (gimp-image-get-active-layer image)) ORIENTATION-HORIZONTAL FALSE imageWidth)
  ;merge layers
  (gimp-image-merge-down image (car (gimp-image-get-active-layer image)) 0)
)

(define (script-fu-horizontal-mirror image
                                     drawable)
 (gimp-image-undo-group-start image)
 (let*
  (
   (imageWidth (car (gimp-image-width image)))
   (newWidth (* 2 imageWidth))
   (imageHeight (car (gimp-image-height image)))
  )
  (mirror_flip image imageWidth newWidth imageHeight)
  (gimp-displays-flush)
 )
 (gimp-image-undo-group-end image)
)

(script-fu-register
 "script-fu-horizontal-mirror"
 "Horizontal Mirror"
 "Duplicates Image and mirrors horizontally."
 "Cory Gugler"
 "Do what you want"
 "10-06-2013"
 "RGB* GRAY*"
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 )
(script-fu-menu-register "script-fu-horizontal-mirror" "<Image>/Image/Transform")
