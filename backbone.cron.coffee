#jshint strict:false, forin:false, loopfunc:true
#global _, Backbone

class Backbone.Cron
  constructor: (@owner, crontabs, autostart = true) ->
    seqArray = (from, to) -> _.map(new Array(to - from + 1).join().split(','), (v, i, a) -> i + from)
    parseCrontab = (crontab) =>
      ctArray = _.map(crontab.split(/\s+/), (v, i, a) ->
        return v if i is 6 or v is '*'
        v = v.replace /(\d+)-(\d+)/g, (vm, vf, vt) -> seqArray(Number(vf), Number(vt)).join()
        v = v.replace /\*\/(\d+)/g, (vm, vi) -> Number(vi) * -1
        _.map(v.split(','), (vv, vi, va) -> Number vv).sort())
      unit: @_makeunit ctArray
      exec: ctArray[6]

    @items = {}
    @items[label] = _.extend parseCrontab(ct), { crontab: ct, pause: false } for label, ct of crontabs
    @owner.bind 'remove', () => @stop() unless @owner.model?
    @start() if autostart

  start: () =>
    @unixtime = parseInt(new Date() / 1000, 10)
    @timer = setInterval () =>
      d = new Date(++@unixtime * 1000)
      now = @_makeunit [ d.getSeconds(), d.getMinutes(), d.getHours(), d.getDate(), d.getMonth() + 1, d.getDay() ]
      for label, item of @items when not item.pause
        @owner[item.exec] label, d if _.every item.unit, (v, k ,o) -> v? and (v is '*' or _.some(v, (vv, vi, va) -> if vv < 0 then now[k] % (vv * -1) is 0 else vv is now[k]))
    , 1000

  stop: () => clearInterval @timer
  on: (label) => @items[label].pause = false
  off: (label) => @items[label].pause = true
  _makeunit: (array) => _.object [ 'second', 'minute', 'hour', 'day', 'month', 'weekday' ], array
