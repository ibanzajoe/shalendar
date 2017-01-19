module Shalendar

  class Instagram

    def initialize(client)
      @client = client
    end

    def sync(user)

      html = ''
      uid = @client.user.id
      max_id = nil
      min_id = nil
      opts = {
        :count => 1
      }

      cnt = 0

      loop do
        cnt = cnt + 1
        p "loop #{cnt}"
        if !max_id.nil?
          opts[:max_id] = max_id
        end

        if !min_id.nil?
          opts[:min_id] = min_id
        end

        res = @client.user_recent_media(uid, opts)
        for media_item in res
          html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'><br/> Created: #{media_item.created_time}  <br/>LikesCount=#{media_item.likes[:count]}</div>"
        end

        if res.pagination.nil? && res.pagination.next_max_id.nil?
          break
        else
          if res.pagination.next_max_id
            max_id = res.pagination.next_max_id.split("_")[0].to_i
          else
            break
          end
        end

      end

      html = "<h3>wtf</h3> #{html}"
      return html


      html = ''

      opts = {
        :max_id => 20,
        :min_id => 20,
        :count => 20,
      }

      res = @instagram.user_recent_media(@instagram.user.id, opts)

      for media_item in res
        html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'><br/> Created: #{media_item.created_time}  <br/>Likes: #{media_item.likes[:count]}<br>#{media_item.id}</div>"
      end

      return html

    end

  end


end
