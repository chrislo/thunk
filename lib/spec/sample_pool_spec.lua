describe('SamplePool', function()
    setup(function()
        SamplePool = require("lib/sample_pool")
    end)

    before_each(function()
        engine = { load_sample = function(idx, fn) end }
        s = SamplePool:new(engine)
    end)

    describe('add()', function()
        it('should set the filename of the sample at index', function()
            s:add('foo', 1)

            assert.same('foo', s.samples[1].fn)
        end)

        it('should tell the engine to load the sample', function()
            stub(engine, "load_sample")
            s:add('foo', 1)

            assert.stub(engine.load_sample).was.called_with(1, 'foo')

            engine.load_sample:revert()
        end)
    end)

    describe('add()', function()
        it('should add each file in the directory', function()
            stub(util, 'scandir', function(dir) return { "foo" } end)
            stub(engine, "load_sample")

            s:add_dir('dirname/')

            assert.stub(engine.load_sample).was.called_with(1, 'dirname/foo')
            engine.load_sample:revert()
            util.scandir:revert()
        end)
    end)

    describe('has_sample()', function()
        it('returns true if the sample has been added, false otherwise', function()
            stub(engine, "load_sample")
            assert.same(false, s:has_sample(1))

            s:add('foo', 1)
            assert.same(true, s:has_sample(1))
        end)
    end)

    describe('name()', function()
        it('returns ', function()
            stub(engine, "load_sample")
            s:add('/home/foo/kick.wav', 1)

            assert.same('kick.wav', s:name(1))
        end)
    end)
end)
