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

            local state = State:new()
            state.selected_step = 1
            state.sample_pool = sample_pool
        end)

        describe('when the edit_mode is step', function()
            before_each(function()
                state.edit_mode = 'step'
                entries = ScreenUI.menu_entries(state)
                selected_step = state.pattern.tracks[state.selected_track].steps[state.selected_step]
            end)

            it("displays the selected step sample", function()
                local label = entries[1].label
                assert.is_truthy(label:match("^sample.*foo$"))
            end)

            it("allows us to change the sample", function()
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

        describe('when the edit_mode is pattern', function()
            _G.params = {
              get = function(x) return 100 end
            }

            before_each(function()
                state.edit_mode = 'pattern'
                entries = ScreenUI.menu_entries(state)
            end)

            it("displays the tempo", function()
                local label = entries[1].label
                assert.is_truthy(label:match("^tempo.*$"))
            end)

            it("displays the swing", function()
                local label = entries[2].label
                assert.is_truthy(label:match("^swing.*$"))
            end)

            it("sets the edit mode to sample", function()
                assert.are.equal('pattern', state.edit_mode)
                entries[3].handler()
                assert.are.equal('samples', state.edit_mode)
            end)
        end)

        describe('when the edit_mode is samples', function()
            before_each(function()
                local engine = {
                  load_sample = function() end
                }
                local sample_pool = SamplePool:new(engine)
                sample_pool:add('/sample/foo.wav', 1)
                state.sample_pool = sample_pool

                state.edit_mode = 'samples'
                entries = ScreenUI.menu_entries(state)
            end)

            it("lists all the loaded samples", function()
                assert.are.equal(64, table.getn(entries))
                assert.are.equal('foo.wav', entries[1].label)
            end)
        end)
    end)
end)
