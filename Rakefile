#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'railforum'




task :default => [:crawl]


# 巡回
desc "Regular crawling."
task :crawl => [:get, :contents]


# 未読の取得
desc "Retrive new contents."
task :get => [:init] do
  rail_get = RailForum::RailForumGet.new
  rail_get.get
end


# 未読の表示
desc "Print unread contents."
task :contents, [:bbs] => [:init] do |task,arg|
  rail_view = RailForum::RailForumView.new
  rail_view.contents(arg[:bbs])
end


# タイトルの表示
desc "Print unread contents' subject."
task :subjects, [:bbs] => [:init] do |task,arg|
  rail_view = RailForum::RailForumView.new
  rail_view.subjects(arg[:bbs])
end


# DBのマイグレーション
desc "Migrate database."
task :db_migrate => [:init] do
  RailForum::Migration.up
end


# 初期化
task :init do
  require 'migrate'
  RailForum::Init.init
end
