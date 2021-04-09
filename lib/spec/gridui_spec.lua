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
        it("should indicate the currently selected track's page", function()
            local pattern = Pattern.new()

            local selected_track = 1
            local selected_page = {1, 1, 1, 1, 1, 1}

            GridUI.redraw(connection, pattern, selected_track, selected_page)

            assert.stub(connection.led).was.called_with(_, 5, 3, 15)
        end)

        it("should indicate how many pages the currently selected track has", function()
            local pattern = Pattern.new()
            local selected_track = 1
            local selected_page = {1, 1, 1, 1, 1, 1}

            -- make sure the pattern has 2 pages
            pattern = Pattern.maybeCreatePage(pattern, selected_track, 2)

            GridUI.redraw(connection, pattern, selected_track, selected_page)

            assert.stub(connection.led).was.called_with(_, 5, 3, 15)
            assert.stub(connection.led).was.called_with(_, 6, 3, 5)
        end)

        it("should show active steps for the selected track", function()
            local selected_track = 1
            local selected_page = {1, 1, 1, 1, 1, 1}

            local pattern = Pattern.new()
            pattern = Pattern.toggleStep(pattern, 1, selected_track)

            GridUI.redraw(connection, pattern, selected_track, selected_page)

            assert.stub(connection.led).was.called_with(_, 1, 1, 15)
        end)

        it("should show active steps for the selected track in the selected page", function()
            local selected_track = 1
            local selected_page = {2, 1, 1, 1, 1, 1}

            local pattern = Pattern.new()
            pattern = Pattern.toggleStep(pattern, 17, selected_track)

            GridUI.redraw(connection, pattern, selected_track, selected_page)

            assert.stub(connection.led).was.called_with(_, 1, 1, 15)
        end)

        it("should not show active steps for the selected track if not in the page", function()
            local selected_track = 1
            local selected_page = {2, 1, 1, 1, 1, 1}

            local pattern = Pattern.new()
            pattern = Pattern.toggleStep(pattern, 1, selected_track)

            GridUI.redraw(connection, pattern, selected_track, selected_page)

            assert.stub(connection.led).was.not_called_with(_, 1, 1, 15)
        end)

        it("should show the current playhead position for the selected track", function()
            local selected_track = 1
            local selected_page = {1, 1, 1, 1, 1, 1}

            local ppqn = 4
            local pattern = Pattern.new(4)

            GridUI.redraw(connection, pattern, selected_track, selected_page)
            assert.stub(connection.led).was.called_with(_, 1, 1, 5)

            pattern = Pattern.advance(pattern)
            GridUI.redraw(connection, pattern, selected_track, selected_page)
            assert.stub(connection.led).was.called_with(_, 2, 1, 5)
        end)
    end)
end)
