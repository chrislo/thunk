describe('controller', function()
    setup(function()
        Controller = require("lib/controller")
        _ = require("luassert.match")._
    end)

    describe('handle_short_press', function()
        it("sets the track length when shift is pressed", function()
            local state = State:new()
            state.shift = true

            assert.same(16, state.pattern.tracks[state.selected_track].length)
            Controller.handle_short_press(state, 8, 1)
            assert.same(8, state.pattern.tracks[state.selected_track].length)
        end)

        it("toggle steps for the selected track and page", function()
            local state = State:new()
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
            state:select_page(2)
            Controller.handle_short_press(state, 1, 1)
            assert.spy(Pattern.toggleStep).was_called_with(_, 17, 1)
            Pattern.toggleStep:clear()

            -- Step toggle on first page, second track of step editor
            state:select_track(2)
            Controller.handle_short_press(state, 1, 1)
            assert.spy(Pattern.toggleStep).was_called_with(_, 1, 2)
            Pattern.toggleStep:clear()
        end)

        it("selects the step page of the current track", function()
            local state = State:new()
            state:select_track(1)
            state:select_page(1)

            Controller.handle_short_press(state, 6, 3)
            assert.same(2, state:current_page())
        end)
    end)
end)
