describe('track', function()
    setup(function()
        track = require("lib/track")
        _G.params = {
          get = function(name, value)
            if value == 'clock_tempo' then
              return 120
            end
          end
        }
    end)

    describe('new()', function()
        it('should have an initial position', function()
            assert.same(1, track:new().pos)
        end)
    end)

    describe('advance()', function()
        it('should return a new track with tick incremented by 1', function()
            t = track:new()
            t:advance()

            assert.same(1, t.tick)
        end)

        it('with 4 pulses per quarter note it should move to the next step every tick', function()
            t = track:new()
            t:advance()

            assert.same(2, t.pos)
        end)

        it('with 8 pulses per quarter note it should move to the next step every 2 ticks', function()
            local t = track:new(8)
            assert.same(1, t.pos)

            t:advance()
            assert.same(1, t.pos)

            t:advance()
            assert.same(2, t.pos)
        end)

        it('should return to beginning when advanced past the track length', function()
            local p = track:new()

            for i = 1, 16 do
              p:advance()
            end
            assert.same(1, p.pos)
        end)
    end)

    describe('playStep()', function()
        it('does not play inactive steps', function()
            local t = track:new()

            local engine = {
              note_on = function(id, sampleId, vel, rate) end
            }
            stub(engine, 'note_on')

            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_not_called()
        end)

        it('plays active steps', function()
            local t = track:new()
            t:toggleStep(1)

            local engine = {
              note_on = function(id, sampleId, vel, rate) end
            }
            stub(engine, 'note_on')

            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_called()
        end)

        it('plays active steps only when the position in the step equals the offset', function()
            local t = track:new(8)
            t:toggleStep(1)
            t.steps[1].offset = 1

            local engine = {
              note_on = function(id, sampleId, vel, rate) end
            }
            stub(engine, 'note_on')

            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_not_called()

            t:advance(t)
            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_called()
        end)

        it('plays even active steps late if they are swung', function()
            local t = track:new(8)
            t:toggleStep(1)
            t:toggleStep(2)
            t:setSwing(1)

            local engine = {
              note_on = function(id, sampleId, vel, rate) end
            }
            stub(engine, 'note_on')

            -- First step is odd and not swung so should play on tick 1
            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_called()
            engine.note_on:clear()

            -- But not on tick 2
            t:advance()
            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_not_called()
            engine.note_on:clear()

            -- Second step is even and swung so should not play on tick 3
            t:advance()
            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_not_called()
            engine.note_on:clear()

            -- But should play on tick 4
            t:advance()
            t:playStep(engine, 1)
            assert.stub(engine.note_on).was_called()
            engine.note_on:clear()
        end)
    end)

    describe('toggleStep()', function()
        it('sets the step to true if it is false and vice versa', function()
            local p = track:new()
            assert.is_false(p.steps[1].active)

            p:toggleStep(16)
            assert.is_true(p.steps[16].active)
        end)
    end)

    describe('reset()', function()
        it('resets the track position to 1', function()
            local t = track:new()
            t:advance()
            assert.is.equal(2, t.pos)

            t:reset()

            assert.is.equal(1, t.pos)
        end)
    end)

    describe('currentlyPlayingStep()', function()
        it('returns the current step', function()
            local t = track:new()

            assert.is_true(t:currentlyPlayingStep().current)
        end)
    end)

    describe('maybeCreatePage()', function()
        it('does not alter the track length when the track already has the page', function()
            local t = track:new()
            t:maybeCreatePage(1)
            assert.is_same(16, t.length)

            local t = track:new()
            t.length = 32
            t:maybeCreatePage(2)
            assert.is_same(32, t.length)
        end)

        it('increases the track length when the track does not have the page', function()
            local t = track:new()
            t:maybeCreatePage(2)
            assert.is_same(32, t.length)

            local t = track:new()
            t:maybeCreatePage(4)
            assert.is_same(64, t.length)

            local t = track:new()
            t.length = 8
            t:maybeCreatePage(1)
            assert.is_same(8, t.length)
            t:maybeCreatePage(2)
            assert.is_same(32, t.length)
        end)
    end)
end)
