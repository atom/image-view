{View, $} = require 'atom-space-pen-views'
ImageEditorView = require '../lib/image-editor-view'
ImageEditor = require '../lib/image-editor'

describe "ImageEditorView", ->
  [editor, view, filePath, workspaceElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    filePath = atom.project.getDirectories()[0].resolve('binary-file.png')
    editor = new ImageEditor(filePath)
    view = new ImageEditorView(editor)
    view.height(100)
    jasmine.attachToDOM(view.element)

    waitsFor -> view.loaded

  afterEach ->
    editor.destroy()
    view.remove()

  it "displays the image for a path", ->
    expect(view.image.attr('src')).toContain filePath

  describe "when the image is changed", ->
    it "reloads the image", ->
      spyOn(view, 'updateImageURI')
      editor.file.emitter.emit('did-change')
      expect(view.updateImageURI).toHaveBeenCalled()

  describe "when the image is moved", ->
    it "updates the title", ->
      titleHandler = jasmine.createSpy('titleHandler')
      editor.onDidChangeTitle(titleHandler)
      editor.file.emitter.emit('did-rename')

      expect(titleHandler).toHaveBeenCalled()

  describe "image-view:reload", ->
    it "reloads the image", ->
      spyOn(view, 'updateImageURI')
      atom.commands.dispatch view.element, 'image-view:reload'
      expect(view.updateImageURI).toHaveBeenCalled()

  describe "image-view:zoom-in", ->
    it "increases the image size by 25%", ->
      atom.commands.dispatch view.element, 'image-view:zoom-in'
      expect(view.image.width()).toBe 13
      expect(view.image.height()).toBe 13

  describe "image-view:zoom-out", ->
    it "decreases the image size by 25%", ->
      atom.commands.dispatch view.element, 'image-view:zoom-out'
      expect(view.image.width()).toBe 8
      expect(view.image.height()).toBe 8

  describe "image-view:reset-zoom", ->
    it "restores the image to the original size", ->
      atom.commands.dispatch view.element, 'image-view:zoom-in'
      expect(view.image.width()).not.toBe 10
      expect(view.image.height()).not.toBe 10
      atom.commands.dispatch view.element, 'image-view:reset-zoom'
      expect(view.image.width()).toBe 10
      expect(view.image.height()).toBe 10

  describe "ImageEditorStatusView", ->
    [imageSizeStatus] = []

    beforeEach ->
      view.detach()
      jasmine.attachToDOM(workspaceElement)

      waitsForPromise ->
        atom.packages.activatePackage('image-view')

      waitsForPromise ->
        atom.workspace.open(filePath)

      runs ->
        editor = atom.workspace.getActivePaneItem()
        view = $(atom.views.getView(atom.workspace.getActivePaneItem())).view()
        view.height(100)

      waitsFor -> view.loaded

      waitsForPromise ->
        atom.packages.activatePackage('status-bar')

      runs ->
        statusBar = workspaceElement.querySelector('status-bar')
        imageSizeStatus = $(statusBar.leftPanel.querySelector('.status-image')).view()
        expect(imageSizeStatus).toExist()

    it "displays the size of the image", ->
      expect(imageSizeStatus.text()).toBe '10x10'
