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

          # default to image
          type = 'image'
          image_url = media_item.images.standard_resolution.url
          video_url = nil

          # if video provided
          if !media_item.videos.blank?
            video_url = media_item.videos.standard_resolution.url
            type = 'video'
          end

          # if caption provided, set title
          title = media_item.caption[:text] || ''

          html << "<div style='float:left;'><img src='#{media_item.images.thumbnail.url}'><br/> Created: #{media_item.created_time}  <br/>LikesCount=#{media_item.likes[:count]}</div>"

          payload = {
            :user_id => user[:id],
            :provider => 'instagram',
            :refid => media_item.id,
            :type => type,
            :title => title,
            :description => '',
            :image_url => image_url,
            :video_url => video_url,
            :data => media_item.to_json,
            :origin_at => Time.at(media_item.created_time.to_i).to_datetime,
          }

          p "wtf is this"
          p payload

          Media.create(payload)
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
