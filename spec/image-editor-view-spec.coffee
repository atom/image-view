ImageEditorView = require '../lib/image-editor-view'
ImageEditor = require '../lib/image-editor'

describe "ImageEditorView", ->
  [editor, view, filePath] = []

  beforeEach ->
    filePath = atom.project.resolve('binary-file.png')
    editor = new ImageEditor(filePath)
    view = new ImageEditorView(editor)
    view.attachToDom()
    view.height(100)

    waitsFor -> view.loaded

  it "displays the image for a path", ->
    expect(view.image.attr('src')).toBe filePath

  it "centers the image in the editor", ->
    expect(view.image.width()).toBe 10
    expect(view.image.height()).toBe 10
    expect(view.image.css('left')).toBe "#{(view.width() - view.image.outerWidth()) / 2}px"
    expect(view.image.css('top')).toBe "#{(view.height() - view.image.outerHeight()) / 2}px"

  describe "image-view:zoom-in", ->
    it "increases the image size by 10%", ->
      view.trigger 'image-view:zoom-in'
      expect(view.image.width()).toBe 11
      expect(view.image.height()).toBe 11

  describe "image-view:zoom-out", ->
    it "decreases the image size by 10%", ->
      view.trigger 'image-view:zoom-out'
      expect(view.image.width()).toBe 9
      expect(view.image.height()).toBe 9

  describe "image-view:reset-zoom", ->
    it "restores the image to the original size", ->
      view.trigger 'image-view:zoom-in'
      expect(view.image.width()).not.toBe 10
      expect(view.image.height()).not.toBe 10
      view.trigger 'image-view:reset-zoom'
      expect(view.image.width()).toBe 10
      expect(view.image.height()).toBe 10
