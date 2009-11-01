#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# 「bbs」のコントローラ
#

require 'time'
require 'open-uri'
require 'rss'

require 'config'
require 'controllers/http_access'
require 'models/bbs'


module RailForum
  class BBSController
    attr_accessor :bbs, :contents_ctls

    @bbs                = nil
    @contents_ctls      = nil
    @rss                = nil

    #--------------------------------------------------
    def initialize(bbs=nil)
      if bbs
        @bbs = bbs
      else
        @bbs = RailForum::BBS.new
      end
    end

    #--------------------------------------------------
    def find_by_number(bbs_number)
      bbs = RailForum::BBS.find(:first, :conditions => ["bbs_number=#{bbs_number}"])
      # 変数初期化
      @contents_ctls = nil
      @rss = nil

      if bbs
        @bbs = bbs
      else
        @bbs.bbs_number   = bbs_number    # 掲示板番号
        @bbs.rss_url      = RailForum::Config[:RSSBase] + "/bbs_#{@bbs.bbs_number}.xml"
                                        # RSSのURL
        # RSSからタイトルを取得
        get_rss
        @bbs.subject = @rss.channel.title
      end
    end

    #--------------------------------------------------
    def get_content_urls
      if @contents_ctls
        return @contents_ctls
      end

      # RSSを取得して、各記事のリンク先URLを取得
      get_rss
      @contents_ctls = []
      @rss.items.reverse_each {|item|
        if !@bbs.last_post_at || item.date > @bbs.last_post_at
          content = @bbs.contents.build
          content.url = item.link
          contents_ctl = RailForum::ContentsController.new(content)
          @contents_ctls << contents_ctl
        end
      }
      return @contents_ctls
    end

    #--------------------------------------------------
    def get_contents
      if !@contents_ctls || @contents_ctls == []
        return nil
      end

      # 各contentのcontrollerで内容を取得
      @contents_ctls.each {|ctl|
        ctl.get
        ctl.parse
      }
      @bbs.last_post_at = @contents_ctls.last.content.posted_at
    end

    #--------------------------------------------------
    def save
      @bbs.save
      @contents_ctls = nil
      return @bbs
    end

    #==================================================
    private
    def get_rss
      if @rss
        return @rss
      end

      # RSSを取得して解析
      @rss = open(@bbs.rss_url) {|http|
        rss_xml = http.read
        RSS::Parser.parse(rss_xml, false)
      }
    end

  end # end of class
end # end of module
