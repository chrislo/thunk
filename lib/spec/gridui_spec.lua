describe('gridui', function()
    setup(function()
        GridUI = require("lib/gridui")
        _ = require("luassert.match")._
    end)

    describe('redraw', function()
        it("should indicate the currently selected track's page", function()
            local connection = {}
            stub(connection, 'all')
            stub(connection, 'refresh')
            stub(connection, 'led')

            local pattern = Pattern.new()

            local selected_track = 1
            local selected_page = {1, 1, 1, 1, 1, 1}

            GridUI.redraw(connection, pattern, selected_track, selected_page)

            assert.stub(connection.led).was.called_with(_, 5, 3, 15)
        end)
    end)
end)
