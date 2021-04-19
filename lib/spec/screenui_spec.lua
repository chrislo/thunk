describe('screenui', function()
    setup(function()
        ScreenUI = require("lib/screenui")
        _ = require("luassert.match")._
    end)

    describe('menu_entries', function()
        local entries, selected_step

        before_each(function()
            local state = {
              pattern = Pattern.new(),
              selected_track = 1,
              selected_step = 1,
            }

            entries = ScreenUI.menu_entries(state)
            selected_step = state.pattern.tracks[state.selected_track].steps[state.selected_step]
        end)

        it("displays the selected step offset", function()
            local label = entries[1].label
            assert.is_truthy(label:match("^offset.*0$"))
        end)

        it("allows us to change the selected step offset", function()
            assert.are.equal(0, selected_step.offset)
            entries[1].handler(1)
            assert.are.equal(1, selected_step.offset)
        end)

        it("displays the selected step velocity", function()
            local label = entries[2].label
            assert.is_truthy(label:match("^velocity.*1$"))
        end)

        it("allows us to change the selected step velocity", function()
            assert.are.equal(1, selected_step.velocity)
            entries[2].handler(-1)
            assert.are.equal(0.9, selected_step.velocity)
        end)
    end)
end)
