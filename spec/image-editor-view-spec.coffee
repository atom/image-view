ImageEditorView = require '../lib/image-editor-view'
ImageEditor = require '../lib/image-editor'

describe "ImageEditorView", ->
  [view, path] = []

  beforeEach ->
    path = atom.project.resolve('binary-file.png')
    view = new ImageEditorView()
    view.attachToDom()
    view.height(100)

  it "displays the image for a path", ->
    view.setModel(new ImageEditor({path}))
    expect(view.image.attr('src')).toBe path

  it "centers the image in the editor", ->
    imageLoaded = false
    view.image.load =>
      imageLoaded = true
    view.setModel(new ImageEditor({path}))

    waitsFor ->
      imageLoaded

    runs ->
      expect(view.image.width()).toBe 10
      expect(view.image.height()).toBe 10
      expect(view.image.css('left')).toBe "#{(view.width() - view.image.outerWidth()) / 2}px"
      expect(view.image.css('top')).toBe "#{(view.height() - view.image.outerHeight()) / 2}px"

  describe "image-view:zoom-in", ->
    it "increases the image size by 10%", ->
      imageLoaded = false
      view.image.load =>
        imageLoaded = true
      view.setModel(new ImageEditor({path}))

      waitsFor ->
        imageLoaded

      runs ->
        view.trigger 'image-view:zoom-in'
        expect(view.image.width()).toBe 11
        expect(view.image.height()).toBe 11

  describe "image-view:zoom-out", ->
    it "decreases the image size by 10%", ->
      imageLoaded = false
      view.image.load =>
        imageLoaded = true
      view.setModel(new ImageEditor({path}))

      waitsFor ->
        imageLoaded

      runs ->
        view.trigger 'image-view:zoom-out'
        expect(view.image.width()).toBe 9
        expect(view.image.height()).toBe 9

  describe "image-view:reset-zoom", ->
    it "restores the image to the original size", ->
      imageLoaded = false
      view.image.load =>
        imageLoaded = true
      view.setModel(new ImageEditor({path}))

      waitsFor ->
        imageLoaded

      runs ->
        view.trigger 'image-view:zoom-in'
        expect(view.image.width()).not.toBe 10
        expect(view.image.height()).not.toBe 10
        view.trigger 'image-view:reset-zoom'
        expect(view.image.width()).toBe 10
        expect(view.image.height()).toBe 10
