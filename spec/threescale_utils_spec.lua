local _M = require('apicast.threescale_utils')

describe('3scale utils', function()
    describe('.error', function()
        it('returns concatenated error in timer phase', function()
            local get_phase = spy.on(ngx, 'get_phase', function() return 'timer' end)
            local error = _M.error('one', ' two', ' three')

            assert.spy(get_phase).was_called(1)

            assert.equal('one two three', error)
        end)

        it('.error fails the nginx chain', function()
            stub(ngx, 'get_phase', function() return 'init' end)
            stub(ngx, 'say', function(...) return nil end)
            local exit = spy.on(ngx, 'exit', function(s) return 'exited!' end)

            local error = _M.error('cache issue ' .. 'host:' .. 6379)

            assert.spy(ngx.exit).was_called(1)
            assert.spy(ngx.say).was.called_with('cache issue ' .. 'host:' .. 6379)
        end)

        it('.error_gracefully logs the error without exiting chain', function()
            stub(ngx, 'get_phase', function() return 'init' end)
            stub(ngx, 'say', function(...) return nil end)

            local exit = spy.on(ngx, 'exit', function(s) return 'exited!' end)
            local error = _M.error_gracefully('redis is not reachable')

            assert.spy(ngx.exit).was_not_called()
            assert.spy(ngx.say).was.called_with('redis is not reachable')
        end)
    end)
end)
