describe('screenui', function()
    setup(function()
        ScreenUI = require("lib/screenui")
        _ = require("luassert.match")._
    end)

    describe('menu_entries', function()
        local entries, selected_step

        before_each(function()
            local sample_pool = {
              name = function(x) return 'foo' end
            }

            local state = {
              pattern = Pattern:new(),
              selected_track = 1,
              selected_step = 1,
              edit_mode = 'step',
              sample_pool = sample_pool
            }

            entries = ScreenUI.menu_entries(state)
            selected_step = state.pattern.tracks[state.selected_track].steps[state.selected_step]
        end)

        it("displays the selected step sample", function()
            local label = entries[1].label
            assert.is_truthy(label:match("^sample.*foo$"))
        end)

        it("allows us to change the sample #wip", function()
            assert.are.equal(nil, selected_step.sample_id)
            entries[1].handler(1)
            assert.are.equal(2, selected_step.sample_id)
        end)

        it("displays the selected step offset", function()
            local label = entries[2].label
            assert.is_truthy(label:match("^offset.*0$"))
        end)

        it("allows us to change the selected step offset", function()
            assert.are.equal(0, selected_step.offset)
            entries[2].handler(1)
            assert.are.equal(1, selected_step.offset)
        end)

        it("displays the selected step velocity", function()
            local label = entries[3].label
            assert.is_truthy(label:match("^velocity.*127\.00$"))
        end)

        it("allows us to change the selected step velocity", function()
            assert.are.equal(127, selected_step.velocity)
            entries[3].handler(-1)
            assert.are.equal(126, selected_step.velocity)
        end)
    end)
end)
