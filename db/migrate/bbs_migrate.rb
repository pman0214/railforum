#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forumの1つの掲示板を格納するテーブルの
# migration
#

require 'activerecord'

module RailForum
  class BBSMigration < ActiveRecord::Migration
    def self.up
      create_table :bbs do |t|
        t.column :bbs_number, :integer, :null => false, :unique => true
                                                                # 掲示板番号
        t.column :rss_url, :string                              # RSSのURL
        t.column :subject, :string                              # タイトル
        t.column :last_post_at, :timestamp                      # 最終発言日時
        t.column :read_point, :integer                          # 既読発言番号
        t.column :created_at, :timestamp                        # （自動入力）
      end
    end

    def self.down
      drop_table :bbs
    end

  end # end of class
end # end of module
