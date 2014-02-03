_ = require 'underscore-plus'
{$, ScrollView} = require 'atom'

# Renders the image in an {ImageEditor}.
module.exports =
class ImageEditorView extends ScrollView
  @content: ->
    @div class: 'image-view', tabindex: -1, =>
      @div class: 'image-container', =>
        @img outlet: 'image'

  initialize: (editor) ->
    super

    @loaded = false
    @image.hide().attr('src', editor.path)

    @image.load =>
      @originalHeight = @image.height()
      @originalWidth = @image.width()
      @loaded = true
      @centerImage()

    @subscribe $(window), 'resize', _.debounce((=> @centerImage()), 300)
    @command 'image-view:zoom-in', => @zoomIn()
    @command 'image-view:zoom-out', => @zoomOut()
    @command 'image-view:reset-zoom', => @resetZoom()

  afterAttach: (onDom) ->
    return unless onDom

    if pane = @getPane()
      @active = @is(pane.activeView)
      @subscribe pane, 'pane:active-item-changed', (event, item) =>
        wasActive = @active
        @active = @is(pane.activeView)
        @centerImage() if @active and not wasActive

  # Places the image in the center of the view.
  centerImage: ->
    return unless @loaded and @isVisible()

    @image.css
      'top': Math.max((@height() - @image.outerHeight()) / 2, 0)
      'left': Math.max((@width() - @image.outerWidth()) / 2, 0)
    @image.show()

  # Retrieves this view's pane.
  #
  # Returns a {Pane}.
  getPane: ->
    @parents('.pane').view()

  # Zooms the image out.
  #
  # This is done by a factor of `0.9`.
  zoomOut: ->
    @adjustSize(0.9)

  # Zooms the image in.
  #
  # This is done by a factor of `1.1`.
  zoomIn: ->
    @adjustSize(1.1)

  # Zooms the image to its normal width and height.
  resetZoom: ->
    return unless @loaded and @isVisible()

    @image.width(@originalWidth)
    @image.height(@originalHeight)
    @centerImage()

  # Adjust the size of the image by the given multiplying factor.
  adjustSize: (factor) ->
    return unless @loaded and @isVisible()

    newWidth = @image.width() * factor
    newHeight = @image.height() * factor
    @image.width(newWidth)
    @image.height(newHeight)
    @centerImage()
