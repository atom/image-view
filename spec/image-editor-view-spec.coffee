{View, $} = require 'atom-space-pen-views'
ImageEditorView = require '../lib/image-editor-view'
ImageEditor = require '../lib/image-editor'

describe "ImageEditorView", ->
  [editor, view, filePath, filePath2, workspaceElement] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    filePath = atom.project.getDirectories()[0].resolve('binary-file.png')
    filePath2 = atom.project.getDirectories()[0].resolve('binary-file-2.png')
    editor = new ImageEditor(filePath)
    view = new ImageEditorView(editor)
    view.height(100)
    jasmine.attachToDOM(view.element)

    waitsFor -> view.loaded

  afterEach ->
    editor.destroy()
    view.remove()

  it "displays the image for a path", ->
    expect(view.image.attr('src')).toContain '/fixtures/binary-file.png'

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

  describe ".adjustSize(factor)", ->
    it "does not allow a zoom percentage lower than 1%", ->
      view.adjustSize(0)
      expect(view.resetZoomButton.text()).toBe '1%'

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

      waitsFor ->
        view.loaded

      waitsForPromise ->
        atom.packages.activatePackage('status-bar')

      runs ->
        statusBar = workspaceElement.querySelector('status-bar')
        imageSizeStatus = $(statusBar.leftPanel.querySelector('.status-image')).view()
        expect(imageSizeStatus).toExist()

    it "displays the size of the image", ->
      expect(imageSizeStatus.text()).toBe '10x10'

  describe "when special characters are used in the file name", ->
    describe "when '?' exists in the file name", ->
      it "is replaced with %3F", ->
        newEditor = new ImageEditor('/test/file/?.png')
        expect(newEditor.getURI()).toBe('file:///test/file/%3F.png')

    describe "when '#' exists in the file name", ->
      it "is replaced with %23", ->
        newEditor = new ImageEditor('/test/file/#.png')
        expect(newEditor.getURI()).toBe('file:///test/file/%23.png')

    describe "when '%2F' exists in the file name", ->
      it "should properly encode the %", ->
        newEditor = new ImageEditor('/test/file/%2F.png')
        expect(newEditor.getURI()).toBe('file:///test/file/%252F.png')

    describe "when multiple special characters exist in the file name", ->
      it "are all replaced with escaped characters", ->
        newEditor = new ImageEditor('/test/file/a?#b#?.png')
        expect(newEditor.getURI()).toBe('file:///test/file/a%3F%23b%23%3F.png')

  describe "open many images size", ->
    beforeEach ->
      view.detach()
      jasmine.attachToDOM(workspaceElement)

      waitsForPromise ->
        atom.packages.activatePackage('image-view')

    it "correctly calculates originalWidth and originalHeight for all opened images", ->
      imageEditor1 = null
      imageEditor2 = null
      imageEditorView1 = null
      imageEditorView2 = null

      openedCount = 0
      originalOpen = atom.workspace.open.bind(atom.workspace)
      spyOn(atom.workspace, 'open').andCallFake (uri, options) ->
        originalOpen(uri, options).then -> openedCount++

      runs ->
        atom.workspace.open(filePath)
        atom.workspace.open(filePath2)

      waitsFor 'open to be called twice', ->
        openedCount is 2

      runs ->
        expect(atom.workspace.getActivePane().getItems().length).toBe 2
        imageEditor1 = atom.workspace.getActivePane().getItems()[0]
        imageEditor2 = atom.workspace.getActivePane().getItems()[1]
        expect(imageEditor1).toBe instanceof ImageEditor
        expect(imageEditor2).toBe instanceof ImageEditor

        imageEditorView1 = $(atom.views.getView(imageEditor1)).view()
        imageEditorView2 = $(atom.views.getView(imageEditor2)).view()

      waitsFor ->
        imageEditorView1.loaded
        imageEditorView2.loaded

      runs ->
        expect(imageEditorView1.originalWidth).toBe 10
        expect(imageEditorView1.originalHeight).toBe 10
        expect(imageEditorView2.originalWidth).toBe 10
        expect(imageEditorView2.originalHeight).toBe 10
