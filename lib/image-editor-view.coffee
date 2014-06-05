_ = require 'underscore-plus'
{$, ScrollView} = require 'atom'

# View that renders the image of an {ImageEditor}.
module.exports =
class ImageEditorView extends ScrollView
  @content: ->
    @div class: 'image-view', tabindex: -1, =>
      @div class: 'image-controls', outlet: 'imageControls', =>
        @a class: 'image-controls-color--white', value: '#fff', =>
          @text 'white'
        @a class: 'image-controls-color--black', value: '#000', =>
          @text 'black'
      @div class: 'image-container', =>
        @img outlet: 'image'

  initialize: (editor) ->
    super

    @loaded = false
    @image.hide().attr('src', editor.getUri())

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

      @subscribe atom.workspaceView, 'pane:attached pane:removed', =>
        @centerImage()

      @imageControls.find('a').on 'click', (e) =>
        @changeBackground $(e.target).attr 'value'

  # Places the image in the center of the view.
  centerImage: ->
    return unless @loaded and @isVisible()

    @image.css
      top: Math.max((@height() - @image.outerHeight()) / 2, 0)
      left: Math.max((@width() - @image.outerWidth()) / 2, 0)
    @image.show()

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
    @centerImage()

  # Adjust the size of the image by the given multiplying factor.
  #
  # factor - A {Number} to multiply against the current size.
  adjustSize: (factor) ->
    return unless @loaded and @isVisible()

    newWidth = @image.width() * factor
    newHeight = @image.height() * factor
    @image.width(newWidth)
    @image.height(newHeight)
    @centerImage()

  # Changes the background color of the image view.
  #
  # color - A {String} that is a valid CSS hex color.
  changeBackground: (color) ->
    return unless @loaded and @isVisible and color
    # TODO: in the future, probably validate the color
    @image.css 'background-color', color
