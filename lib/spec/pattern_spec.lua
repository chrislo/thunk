describe('pattern', function()
    setup(function()
        pattern = require("lib/pattern")
    end)

    describe('advance()', function()
        it('should advance each track', function()
            local p = pattern:new()

            assert.same(1, p.tracks[1].pos)
            p:advance()
            assert.same(2, p.tracks[1].pos)
        end)
    end)

    describe('toggleStep()', function()
        it('should return toggle the step for the passed in track', function()
            local p = pattern:new()
            local track = 1

            assert.is_false(p.tracks[track].steps[1].active)
            p:toggleStep(1, track)
            assert.is_true(p.tracks[track].steps[1].active)
        end)
    end)

    describe('currentlyPlayingSteps', function()
        it('returns a table of track to step mappings for the current time', function()
            local p = pattern:new()
            assert.is_true(p:currentlyPlayingSteps()[1].current)
            assert.is_true(p:currentlyPlayingSteps()[2].current)
        end)
    end)

    describe('reset()', function()
        it('should return reset each tracks position to 1', function()
            local p = pattern:new()
            p:advance()

            assert.same(2, p.tracks[1].pos)
            assert.same(2, p.tracks[2].pos)

            p:reset()

            assert.same(1, p.tracks[1].pos)
            assert.same(1, p.tracks[2].pos)
        end)
    end)
end)
