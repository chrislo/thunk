describe('pattern', function()
    setup(function()
        pattern = require("lib/pattern")
    end)

    describe('advance()', function()
        it('should return a new pattern with the position of each track incremented by 1', function()
            local p = pattern.new()

            assert.same(1, p.tracks[1].pos)
            p = pattern.advance(p)
            assert.same(2, p.tracks[1].pos)
        end)
    end)

    describe('toggleStep()', function()
        it('should return toggle the step for the passed in track', function()
            local p = pattern.new()
            local track = 1

            assert.is_false(p.tracks[track].steps[1].active)
            p = pattern.toggleStep(p, 1, track)
            assert.is_true(p.tracks[track].steps[1].active)
        end)
    end)

    describe('currentlyPlayingSteps', function()
        it('returns a table of track to step mappings for the current time', function()
            local p = pattern.new()
            assert.is_true(pattern.currentlyPlayingSteps(p)[1].current)
            assert.is_true(pattern.currentlyPlayingSteps(p)[2].current)
        end)
    end)

    describe('reset()', function()
        it('should return reset each tracks position to 1', function()
            local p = pattern.new()
            pattern.advance(p)

            assert.same(2, p.tracks[1].pos)
            assert.same(2, p.tracks[2].pos)

            pattern.reset(p)

            assert.same(1, p.tracks[1].pos)
            assert.same(1, p.tracks[2].pos)
        end)
    end)
end)
