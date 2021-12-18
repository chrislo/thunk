describe('step', function()
    setup(function()
        track = require("lib/track")
        step = require("lib/step")
    end)

    describe('transpose_or_default()', function()
        setup(function()
            t = track:new()
            s = step:new(t)
        end)

        it('has has zero as a default', function()
            assert.same(0, s:transpose_or_default())
        end)

        it('uses the tracks transpose when the step transpose is nil', function()
            s.transpose = 5
            assert.same(5, s:transpose_or_default())
        end)

        it('sums the tracks transpose and the step transpose', function()
            t.transpose = -12
            s.transpose = 5
            assert.same(-7, s:transpose_or_default())
        end)
    end)
end)
