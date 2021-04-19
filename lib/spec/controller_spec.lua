describe('controller', function()
    setup(function()
        Controller = require("lib/controller")
        _ = require("luassert.match")._
    end)

    describe('handle_short_press', function()
        it("toggle steps for the selected track and page", function()
            local state = {
              pattern = Pattern.new(),
              selected_track = 1,
              selected_page = {1, 1, 1, 1, 1, 1}
            }

            local s = spy.on(Pattern, "toggleStep")

            -- Step toggle on first row of step editor
            Controller.handle_short_press(state, 1, 1)
            assert.spy(Pattern.toggleStep).was_called_with(_, 1, 1)
            Pattern.toggleStep:clear()

            -- Step toggle on second row of step editor
            Controller.handle_short_press(state, 1, 2)
            assert.spy(Pattern.toggleStep).was_called_with(_, 9, 1)
            Pattern.toggleStep:clear()

            -- Step toggle on second page of step editor
            state.selected_page = {2, 1, 1, 1, 1, 1}
            Controller.handle_short_press(state, 1, 1)
            assert.spy(Pattern.toggleStep).was_called_with(_, 17, 1)
            Pattern.toggleStep:clear()

            -- Step toggle on first page, second track of step editor
            state.selected_track = 2
            Controller.handle_short_press(state, 1, 1)
            assert.spy(Pattern.toggleStep).was_called_with(_, 1, 2)
            Pattern.toggleStep:clear()
        end)
    end)
end)
