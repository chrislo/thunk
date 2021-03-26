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
        it('should return a new track with position incremented by 1', function()
            assert.same(2, track.advance(track.new()).pos)
        end)

        it('should return to beginning when advanced past the track length', function()
            local p = track.new()

            for i = 1, 16 do
              p = track.advance(p)
            end
            assert.same(1, p.pos)
        end)
    end)

    describe('toggleStep()', function()
        it('sets the step to true if it is false and vice versa', function()
            local p = track.new()
            assert.same(false, p.steps[1].active)

            p = track.toggleStep(p, 16)
            assert.same(true, p.steps[16].active)
        end)
    end)

    describe('isActive()', function()
        it('returns true if the step is active, false otherwise', function()
            local p = track.new()
            p = track.toggleStep(p, 2);

            assert.same(false, track.isActive(p, 1))
            assert.same(true, track.isActive(p, 2))
        end)
    end)

    describe('currentStep()', function()
        it('returns the current step', function()
            local p = track.new()

            assert.same(true, track.currentStep(p).current)
        end)
    end)
end)
