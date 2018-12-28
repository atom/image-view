const path = require('path');
const _ = require('underscore-plus');
const ImageEditor = require('./image-editor');
const {CompositeDisposable} = require('atom');

module.exports = {
  config: {
    defaultBackgroundColor: {
      type: "string",
      enum: ["white", "black", "transparent"],
      default: "transparent"
    }
  },

  activate() {
    this.statusViewAttached = null;
    this.disposables = new CompositeDisposable;
    this.disposables.add(atom.workspace.addOpener(openURI));
    this.disposables.add(atom.workspace.getCenter().onDidChangeActivePaneItem(() => this.attachImageEditorStatusView()));
  },

  deactivate() {
    if (this.statusViewAttached) {
      this.statusViewAttached.destroy();
    }
    this.disposables.dispose();
  },

  consumeStatusBar(statusBar) {
    this.statusBar = statusBar;
    this.attachImageEditorStatusView();
  },

  attachImageEditorStatusView() {
    if (this.statusViewAttached || this.statusBar == null) {
      return;
    }

    if (!(atom.workspace.getCenter().getActivePaneItem() instanceof ImageEditor)) {
      return;
    }

    const ImageEditorStatusView = require('./image-editor-status-view');
    this.statusViewAttached = new ImageEditorStatusView(this.statusBar);
    this.statusViewAttached.attach();
  },

  deserialize(state) {
    return ImageEditor.deserialize(state);
  }
};

// Files with these extensions will be opened as images
const imageExtensions = ['.bmp', '.gif', '.ico', '.jpeg', '.jpg', '.png', '.webp'];
const openURI = (uriToOpen) => {
  const uriExtension = path.extname(uriToOpen).toLowerCase();
  if (_.include(imageExtensions, uriExtension)) {
    return new ImageEditor(uriToOpen);
  }
};
