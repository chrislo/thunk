describe('pattern', function()
    setup(function()
	pattern = require("lib/pattern")
    end)

    describe('new()', function()
	it('should have an initial position', function()
	    assert.same(1, pattern.new().pos)
	end)
    end)

    describe('advance()', function()
	it('should return a new pattern with position incremented by 1', function()
	    assert.same(2, pattern.advance(pattern.new()).pos)
	end)

	it('should return to beginning when advanced past the pattern length', function()
	    local p = pattern.new()

	    for i = 1, 16 do
	      p = pattern.advance(p)
	    end
	    assert.same(1, p.pos)
	end)
    end)

    describe('toggleStep()', function()
	it('sets the step to true if it is false and vice versa', function()
	    local p = pattern.new()
	    assert.same(false, p.steps[1])

	    p = pattern.toggleStep(p, 16)
	    assert.same(true, p.steps[16])
	end)
    end)

    describe('isActive()', function()
	it('returns true if the step is active, false otherwise', function()
	    local p = pattern.new()
	    p = pattern.toggleStep(p, 2);

	    assert.same(false, pattern.isActive(p, 1))
	    assert.same(true, pattern.isActive(p, 2))
	end)
    end)
end)
