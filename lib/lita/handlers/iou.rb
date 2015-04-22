module Lita
  module Handlers
    class Iou < Handler
      REDIS_KEY = 'iou'
      route(/^!iou\s+([^\s]+)$/i, :add_iou, help: { '!iou [nick]' => 'Owe [nick] one 🍺.'})
      route(/^!iou paid\s+([^\s]+)$/i, :remove_iou, help: { '!iou paid [nick]' => 'Pay back [nick]\'s iou.'})
      route(/^!ious$/i, :show_ious, help: { '!ious' => 'List your outstanding 🍺 ious.'})

      def add_iou(response)
        ower = response.user.name
        owee = response.matches[0][0]
        key = REDIS_KEY + ".#{ower}"
        iou_count = redis.hget(key, owee).to_i
        iou_count += 1
        redis.hset(key, owee, iou_count)
        response.reply "#{ower} now owes #{owee} #{iou_count} #{beer_icons iou_count.to_i }."
      end

      def remove_iou(response)
        ower = response.user.name
        owee = response.matches[0][0]
        key = REDIS_KEY + ".#{ower}"
        iou_count = redis.hget(key, owee).to_i

        if iou_count > 0
          iou_count -= 1
          if iou_count == 0
            redis.hdel(key, owee)
            response.reply "#{ower} has fully paid back #{owee}."
          else
            redis.hset(key, owee, iou_count)
            response.reply "#{ower} now owes #{owee} #{iou_count} #{beer_icons iou_count.to_i }."
          end
        end
      end

      def show_ious(response)
        ower = response.user.name
        key = REDIS_KEY + ".#{ower}"
        ious = redis.hgetall(key)

        if ious.length == 0
          response.reply "#{ower} owes nothing."
        else
          reply_str = "#{ower} owes"
          data_str = ''
          ious.each do |nick, num|
            data_str += " #{nick} #{beer_icons num.to_i}," #beer#{(num.to_i > 1)? 's' : ''},
          end
          data_str.sub! /,$/, ''
          response.reply reply_str + data_str
        end
      end

      def beer_icons(count)
        str = ''
        0..count.times do
          str += "🍺"
        end
        str
      end
    end

    Lita.register_handler(Iou)
  end
end
