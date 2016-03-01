path = require 'path'
_ = require 'underscore-plus'
ImageEditor = require './image-editor'
{CompositeDisposable} = require 'atom'

module.exports =
  activate: ->
    @statusViewAttached = false
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.addOpener(openURI)
    @disposables.add atom.workspace.onDidChangeActivePaneItem => @attachImageEditorStatusView()

  deactivate: ->
    @disposables.dispose()

  consumeStatusBar: (@statusBar) -> @attachImageEditorStatusView()

  attachImageEditorStatusView: ->
    return if @statusViewAttached
    return unless @statusBar?
    return unless atom.workspace.getActivePaneItem() instanceof ImageEditor

    ImageEditorStatusView = require './image-editor-status-view'
    view = new ImageEditorStatusView(@statusBar)
    view.attach()

    @statusViewAttached = true

# Files with these extensions will be opened as images
imageExtensions = ['.gif', '.ico', '.jpeg', '.jpg', '.png', '.webp']
openURI = (uriToOpen) ->
  uriExtension = path.extname(uriToOpen).toLowerCase()
  if _.include(imageExtensions, uriExtension)
    new ImageEditor(uriToOpen)
