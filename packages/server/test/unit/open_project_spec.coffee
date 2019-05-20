require("../spec_helper")

chokidar = require("chokidar")
browsers = require("#{root}lib/browsers")
Project = require("#{root}lib/project")
openProject = require("#{root}lib/open_project")
preprocessor = require("#{root}lib/background/preprocessor")
serverEvents = require("#{root}lib/background/server_events")

describe "lib/open_project", ->
  beforeEach ->
    @automation = {
      reset: sinon.stub()
      use: sinon.stub()
    }
    @spec = { absolute: "path/to/spec" }
    @browser = { name: "chrome" }
    @config = {
      integrationFolder: "/user/foo/cypress/integration"
      testFiles: "**/*.*"
      ignoreTestFiles: "**/*.nope"
    }

    sinon.stub(browsers, "get").resolves()
    sinon.stub(browsers, "open")
    sinon.stub(Project.prototype, "open").resolves()
    sinon.stub(Project.prototype, "reset").resolves()
    sinon.stub(Project.prototype, "getSpecUrl").resolves()
    sinon.stub(Project.prototype, "getConfig").resolves(@config)
    sinon.stub(Project.prototype, "getAutomation").returns(@automation)
    sinon.stub(preprocessor, "removeFile")

    openProject.create("/project/root")

  context "#launchBrowser", ->
    it "tells preprocessor to remove file on browser close", ->
      openProject.launchBrowser(@browser, @spec)
      .then ->
        browsers.open.lastCall.args[1].onBrowserClose()
        expect(preprocessor.removeFile).to.be.calledWith("path/to/spec")

    it "does not tell preprocessor to remove file if no spec", ->
      openProject.launchBrowser(@browser, {})
      .then ->
        browsers.open.lastCall.args[1].onBrowserClose()
        expect(preprocessor.removeFile).not.to.be.called

    it "runs original onBrowserClose callback on browser close", ->
      onBrowserClose = sinon.stub()
      options = { onBrowserClose }
      openProject.launchBrowser(@browser, @spec, options)
      .then ->
        browsers.open.lastCall.args[1].onBrowserClose()
        expect(onBrowserClose).to.be.called

    it "calls project.reset on launch", ->
      openProject.launchBrowser(@browser, @spec)
      .then ->
        expect(Project.prototype.reset).to.be.called

    it "sets isHeaded + isHeadless if not already defined", ->
      expect(@browser.isHeaded).to.be.undefined
      expect(@browser.isHeadless).to.be.undefined

      openProject.launchBrowser(@browser, @spec)
      .then =>
        expect(@browser.isHeaded).to.be.true
        expect(@browser.isHeadless).to.be.false

<<<<<<< HEAD
    it "executes 'spec:start' event if in interactive mode", ->
      openProject.create("/project/root", {}, { isTextTerminal: false })
      sinon.stub(serverEvents, "execute")

      openProject.launchBrowser(@browser, @spec).then ->
        expect(serverEvents.execute).to.be.calledWith("spec:start")

    it "does not execute 'spec:start' event if in run mode", ->
      openProject.create("/project/root", {}, { isTextTerminal: true })
      sinon.stub(serverEvents, "execute")

      openProject.launchBrowser(@browser, @spec).then ->
        expect(serverEvents.execute).not.to.be.called

  context "#closeBrowser", ->
    beforeEach ->
      sinon.stub(browsers, "close").resolves()

    it "closes the browser", ->
      openProject.closeBrowser().then ->
        expect(browsers.close).to.be.called

    it "executes 'spec:end' event the spec if in interactive mode", ->
      openProject.create("/project/root", {}, { isTextTerminal: false })
      sinon.stub(serverEvents, "execute")

      openProject.launchBrowser(@browser, @spec)
      .then ->
        openProject.closeBrowser()
      .then =>
        expect(serverEvents.execute).to.be.calledWith("spec:end", @spec)

    it "does not execute 'spec:end' event if project not open", ->
      openProject.__reset()
      sinon.stub(serverEvents, "execute")

      openProject.closeBrowser().then ->
        expect(serverEvents.execute).not.to.be.called

    it "does not execute 'spec:end' event if in run mode", ->
      openProject.create("/project/root", {}, { isTextTerminal: true })
      sinon.stub(serverEvents, "execute")

      openProject.closeBrowser().then ->
        expect(serverEvents.execute).not.to.be.called

  context "#close", ->
    it "closes the project if it is open", ->
      project = openProject.getProject()
      sinon.stub(project, "close")
      openProject.close().then ->
        expect(project.close).to.be.called

    it "does not close the project if it is not open", ->
      project = openProject.getProject()
      sinon.stub(project, "close")
      openProject.__reset()
      openProject.close().then ->
        expect(project.close).not.to.be.called
=======
  context "#getSpecChanges", ->
    beforeEach ->
      @watcherStub = {
        on: sinon.stub()
      }
      sinon.stub(chokidar, "watch").returns(@watcherStub)

    it "watches spec files", ->
      openProject.getSpecChanges({}).then =>
        expect(chokidar.watch).to.be.calledWith(@config.testFiles, {
          cwd: @config.integrationFolder
          ignored: @config.ignoreTestFiles
          ignoreInitial: true
        })

    it "calls onChange callback when file is added", ->
      onChange = sinon.spy()
      @watcherStub.on.withArgs("add").yields()
      openProject.getSpecChanges({ onChange }).then =>
        expect(onChange).to.be.called

    it "calls onChange callback when file is removed", ->
      onChange = sinon.spy()
      @watcherStub.on.withArgs("unlink").yields()
      openProject.getSpecChanges({ onChange }).then =>
        expect(onChange).to.be.called

    it "only calls onChange once if there are multiple changes in a row", ->
      onChange = sinon.spy()
      @watcherStub.on.withArgs("unlink").yields()
      @watcherStub.on.withArgs("add").yields()
      @watcherStub.on.withArgs("unlink").yields()
      @watcherStub.on.withArgs("add").yields()
      openProject.getSpecChanges({ onChange }).then =>
        expect(onChange).to.be.calledOnce
>>>>>>> develop
