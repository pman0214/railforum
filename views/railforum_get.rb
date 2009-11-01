#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forum
#    未読取得
#

require 'railforum'


module RailForum
  class RailForumGet
    @account = nil

    #--------------------------------------------------
    def initialize
      # 巡回する掲示板を取得
      @account = RailForum::Account.new(RailForum::Config[:RailForumHome] +
                                     "/" + RailForum::Config[:YamlFile])
      if !@account.exist?
        while !@account.create
        end
      end
    end

    #--------------------------------------------------
    def get
      # ログイン
      http_access = RailForum::HTTPAccess.new
      if !http_access.login?
        print "Logging in...\n"
        http_access.login
        # ログイン失敗時はエラー終了
        if !http_access.login?
          print "Check ID and password.\n"
          print "Abort.\n"
          exit
        end
      end

      @account.bbs.each {|bbs|
        bbs_ctl = RailForum::BBSController.new

        # 掲示板番号でDBから情報取得
        print "Retriving information of bbs ##{bbs}...\n"
        bbs_ctl.find_by_number(bbs)

        # RSSを取得して新しい記事のURLを抽出
        print "Searching for new contents on bbs ##{bbs}...\n"
        bbs_ctl.get_content_urls

        # 新しい記事を取得
        print "Retriving new contents on bbs ##{bbs}...\n"
        bbs_ctl.get_contents

        # DBに保存
        print "Saving...\n"
        bbs_ctl.save
      }

      # ログアウト
      if http_access.login?
        print "Logging out...\n"
        http_access.logout
      end
    end

  end # end of class
end # end of module
