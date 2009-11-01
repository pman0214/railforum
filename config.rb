#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# 設定
#

module RailForum
  Config = {
    # データを保存するディレクトリ
    :RailForumHome      => "#{ENV['HOME']}/.railforum",
    # ログインURL
    :LoginURL         => "https://www.railforum.jp/app/login.php",
    # ログアウトURL
    :LogoutURL        => "https://www.railforum.jp/app/login.php",
    # RSSフィードのベースURL
    :RSSBase          => "http://www.railforum.jp/app/rss10",
    # 設定用YAMLファイル
    :YamlFile         => "config.yml"
  }
end # end of module
