describe('gridui', function()
    setup(function()
        GridUI = require("lib/gridui")
        _ = require("luassert.match")._
    end)

    before_each(function()
        connection = {}
        stub(connection, 'all')
        stub(connection, 'refresh')
        stub(connection, 'led')
    end)

    describe('redraw', function()
        before_each(function()
            state = State:new()
        end)

        it("should indicate the currently selected track's page", function()
            GridUI.redraw(connection, state)

            assert.stub(connection.led).was.called_with(_, 5, 3, 15)
        end)

        it("should indicate how many pages the currently selected track has", function()
            -- make sure the pattern has 2 pages
            state.pattern:maybeCreatePage(state.selected_track, 2)

            GridUI.redraw(connection, state)

            assert.stub(connection.led).was.called_with(_, 5, 3, 15)
            assert.stub(connection.led).was.called_with(_, 6, 3, 5)
        end)

        it("should show active steps for the selected track", function()
            state.pattern:toggleStep(2, state.selected_track)

            GridUI.redraw(connection, state)

            assert.stub(connection.led).was.called_with(_, 2, 1, 15)
        end)

        it("should show active steps for the selected track in the selected page", function()
            state.selected_page = {2, 1, 1, 1, 1, 1}
            state.pattern:toggleStep(17, state.selected_track)

            GridUI.redraw(connection, state)

            assert.stub(connection.led).was.called_with(_, 1, 1, 15)
        end)

        it("should not show active steps for the selected track if not in the page", function()
            state.selected_page = {2, 1, 1, 1, 1, 1}
            state.pattern:toggleStep(1, state.selected_track)

            GridUI.redraw(connection, state)

            assert.stub(connection.led).was.not_called_with(_, 1, 1, 15)
        end)

        it("should show the current playhead position for the selected track", function()
            state.pattern = Pattern:new(4)

            GridUI.redraw(connection, state)
            assert.stub(connection.led).was.called_with(_, 1, 1, 5)

            state.pattern:advance()
            GridUI.redraw(connection, state)
            assert.stub(connection.led).was.called_with(_, 2, 1, 5)
        end)

        it("should indicate the current play state", function()
            state.playing = true

            GridUI.redraw(connection, state)
            assert.stub(connection.led).was.called_with(_, 1, 7, 15)

            state.playing = false
            GridUI.redraw(connection, state)
            assert.stub(connection.led).was.called_with(_, 1, 7, 3)
        end)
    end)
end)
