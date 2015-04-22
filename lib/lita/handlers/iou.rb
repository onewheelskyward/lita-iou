module Lita
  module Handlers
    class Iou < Handler
      REDIS_KEY = 'iou'
      route(/^!iou\s+([^\s]+)$/i, :add_iou)

      def add_iou(response)
        ower = response.user.name
        owee = response.matches[0][0]
        key = REDIS_KEY + ".#{ower}"
        iou_count = redis.hget(key, owee).to_i
        iou_count += 1
        redis.hset(key, owee, iou_count)
        response.reply "#{ower} now owes #{owee} #{iou_count} #{beer_icons iou_count.to_i }."
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
