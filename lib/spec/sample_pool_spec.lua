describe('SamplePool', function()
    setup(function()
        SamplePool = require("lib/sample_pool")
    end)

    before_each(function()
        stub(Timber, 'load_sample')
    end)

    describe('add()', function()
        before_each(function()
            s = SamplePool:new()
        end)

        it('should set the filename of the sample at index', function()
            s:add('foo', 1)

            assert.same('foo', s.samples[1].fn)
        end)

        it('should tell Timber to load the sample', function()
            stub(Timber, "load_sample")
            s:add('foo', 1)

            assert.stub(Timber.load_sample).was.called_with(1, 'foo')

            Timber.load_sample:revert()
        end)
    end)

    describe('add()', function()
        before_each(function()
            s = SamplePool:new()
        end)

        it('should add each file in the directory', function()
            stub(util, 'scandir', function(dir) return { "foo" } end)
            stub(Timber, "load_sample")

            s:add_dir('dirname/')

            assert.stub(Timber.load_sample).was.called_with(1, 'dirname/foo')
            Timber.load_sample:revert()
            util.scandir:revert()
        end)
    end)
end)
