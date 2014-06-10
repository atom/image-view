_ = require 'underscore-plus'
path = require 'path'
{$, ScrollView} = require 'atom'

# View that renders the image of an {ImageEditor}.
module.exports =
class ImageEditorView extends ScrollView
  @content: ->
    @div class: 'image-view', tabindex: -1, =>
      @div class: 'image-controls', outlet: 'imageControls', =>
        @a class: 'image-controls-color-white', value: '#fff', =>
          @text 'white'
        @a class: 'image-controls-color-black', value: '#000', =>
          @text 'black'
      @div class: 'image-container', =>
        @div class: 'image-container-cell', =>
          @img outlet: 'image'

  initialize: (editor) ->
    super

    @loaded = false
    @image.hide().attr('src', editor.getUri())

    @image.load =>
      @originalHeight = @image.height()
      @originalWidth = @image.width()
      @loaded = true
      @image.show()

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
        @image.show() if @active and not wasActive

      @subscribe atom.workspaceView, 'pane:attached pane:removed', =>
        @image.show()

      @imageControls.find('a').on 'click', (e) =>
        @changeBackground $(e.target).attr 'value'

      # Hide controls for jpg and jpeg images as they don't have transparency
      if path.extname(@image.attr 'src').toLowerCase() in ['.jpg', '.jpeg']
        @imageControls.hide()

  # Retrieves this view's pane.
  #
  # Returns a {Pane}.
  getPane: ->
    @parents('.pane').view()

  # Zooms the image out by 10%.
  zoomOut: ->
    @adjustSize(0.9)

  # Zooms the image in by 10%.
  zoomIn: ->
    @adjustSize(1.1)

  # Zooms the image to its normal width and height.
  resetZoom: ->
    return unless @loaded and @isVisible()

    @image.width(@originalWidth)
    @image.height(@originalHeight)
    @image.show()

  # Adjust the size of the image by the given multiplying factor.
  #
  # factor - A {Number} to multiply against the current size.
  adjustSize: (factor) ->
    return unless @loaded and @isVisible()

    newWidth = @image.width() * factor
    newHeight = @image.height() * factor
    @image.width(newWidth)
    @image.height(newHeight)
    @image.show()

  # Changes the background color of the image view.
  #
  # color - A {String} that is a valid CSS hex color.
  changeBackground: (color) ->
    return unless @loaded and @isVisible() and color
    # TODO: in the future, probably validate the color
    @image.css 'background-color', color
