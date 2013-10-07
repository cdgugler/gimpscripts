; Generate header images from scanned images
; Resizes image to MAXWIDTH and copies 
; rows of size HEADERHEIGHT into new layers
; ready to export as separate images

; from horizontal_mirror script, added due to undo issues when attempting to call directly
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

(define (script-fu-wc-process image
                              drawable)
 ; (gimp-image-undo-group-start image)
 (let*
  (
   (imageWidth (car (gimp-image-width image)))
   (imageHeight (car (gimp-image-height image)))
   (MAXWIDTH 1200)
   (HEADERHEIGHT 190)
   (originalLayer (car (gimp-image-get-active-layer image)))
   (numrows 0)
   (newLayer 0)
   (i 0)
  )

  ;mirror across horizontal axis
  ; TODO find out why using script-fu-horizontal-mirror breaks script (error re: undo group)
  ; (script-fu-horizontal-mirror RUN-NONINTERACTIVE image)  ;breaks b/c of undo group
  (mirror_flip image imageWidth (* 2 imageWidth) imageHeight)
  (gimp-displays-flush)

  (set! originalLayer (car (gimp-image-get-active-layer image)))
  ;resize image to max width & maintain aspect ratio
  (gimp-item-transform-scale originalLayer 0 0 MAXWIDTH (* imageHeight (/ MAXWIDTH (* 2 imageWidth))))
  
  ;resize canvas to match layer
  (gimp-image-resize image MAXWIDTH (* imageHeight (/ MAXWIDTH (* 2 imageWidth))) 0 0)
  (gimp-displays-flush)
  
  ;get image dimensions again after resize
  (set! imageWidth (car (gimp-image-width image)))
  (set! imageHeight (car (gimp-image-height image)))

  ;calc max amount of headers to cut according to height
  (set! numrows (floor (/ imageHeight HEADERHEIGHT)))

  ;save layer
  (set! originalLayer (car (gimp-image-get-active-layer image)))
  ;loop through all rows
  (while (< i numrows)
   ;creates selection around current position, vectors x1, y1, x2, y2, x3, y3, x4, y4..
   (gimp-image-select-rectangle image CHANNEL-OP-REPLACE 0 (* HEADERHEIGHT i) imageWidth HEADERHEIGHT)
   (gimp-edit-copy-visible image)
   (gimp-image-insert-layer image 
                            (car (gimp-layer-new image 
                                                 imageWidth 
                                                 HEADERHEIGHT 
                                                 RGBA-IMAGE 
                                                 (string-append "Image0" (number->string i)) 
                                                 100 
                                                 NORMAL-MODE)) 
                            0 
                            1)
   (set! newLayer (car (gimp-edit-paste (car (gimp-image-get-active-layer image)) FALSE)))
   (gimp-layer-translate newLayer (- 0 (car (gimp-drawable-offsets newLayer))) (- 0 (cadr (gimp-drawable-offsets newLayer))))
   (gimp-floating-sel-anchor newLayer)


   (set! i (+ i 1))
   (gimp-image-set-active-layer image originalLayer)
   ;(quit)
  )
  (gimp-image-remove-layer image originalLayer)
  (script-fu-fit-canvas-to-layer image (car (gimp-image-get-active-layer image)))
  
  (gimp-displays-flush)
 )
 ; (gimp-image-undo-group-end image)
)

(script-fu-register
 "script-fu-wc-process"
 "Generate Header Images"
 "Process header images from raw scans for blog"
 "Cory Gugler"
 "Do what you want"
 "10-06-2013"
 "RGB* GRAY*"
 SF-IMAGE "Image" 0
 SF-DRAWABLE "Drawable" 0
 )
(script-fu-menu-register "script-fu-wc-process" "<Image>/Image/Transform")
