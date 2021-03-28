describe('track', function()
    setup(function()
        track = require("lib/track")
    end)

    describe('new()', function()
        it('should have an initial position', function()
            assert.same(1, track.new().pos)
        end)
    end)

    describe('advance()', function()
        it('should return a new track with tick incremented by 1', function()
            assert.same(1, track.advance(track.new()).tick)
        end)

        it('with 4 pulses per quarter note it should move to the next step every tick', function()
            assert.same(2, track.advance(track.new(4)).pos)
        end)

        it('with 8 pulses per quarter note it should move to the next step every 2 ticks', function()
            local t = track.new(8)
            assert.same(1, t.pos)

            t = track.advance(t)
            assert.same(1, t.pos)

            t = track.advance(t)
            assert.same(2, t.pos)
        end)

        it('should return to beginning when advanced past the track length', function()
            local p = track.new()

            for i = 1, 16 do
              p = track.advance(p)
            end
            assert.same(1, p.pos)
        end)
    end)

    describe('offsetEvenSteps()', function()
        it('sets the offset of the even steps', function()
            local t = track.new()
            assert.is_same(0, t.steps[1].offset)
            assert.is_same(0, t.steps[2].offset)
            assert.is_same(0, t.steps[3].offset)
            assert.is_same(0, t.steps[4].offset)

            t = track.offsetEvenSteps(t, 2)

            assert.is_same(0, t.steps[1].offset)
            assert.is_same(2, t.steps[2].offset)
            assert.is_same(0, t.steps[3].offset)
            assert.is_same(2, t.steps[4].offset)
        end)
    end)

    describe('toggleStep()', function()
        it('sets the step to true if it is false and vice versa', function()
            local p = track.new()
            assert.is_false(p.steps[1].active)

            p = track.toggleStep(p, 16)
            assert.is_true(p.steps[16].active)
        end)
    end)

    describe('currentStep()', function()
        it('returns the current step', function()
            local p = track.new()

            assert.is_true(track.currentStep(p).current)
        end)
    end)
end)
