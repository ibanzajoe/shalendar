module Shalendar

  class Instagram

    def initialize(instagram, user)
      @instagram = instagram
      @user = user
    end

    def import()

      html = ''

      res = @instagram.user_recent_media

      return res

      for media_item in res
        html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'><br/> Created: #{media_item.created_time}  <br/>LikesCount=#{media_item.likes[:count]}</div>"
      end

      return html

    end

  end


end
