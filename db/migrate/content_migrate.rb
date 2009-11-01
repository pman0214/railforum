#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forumの1つの発言を格納するテーブルの
# migration
#

require 'activerecord'

module RailForum
  class ContentMigration < ActiveRecord::Migration
    def self.up
      create_table :contents do |t|
        t.column :content_number, :integer, :unique => true     # 発言番号
        t.column :bbs_id, :integer, :null => false              # 掲示板ID（≠掲示板番号）
        t.column :url, :string, :null => false                  # URL
        t.column :subject, :string                              # タイトル
        t.column :author, :string                               # 発言者名
        t.column :posted_at, :timestamp                         # 発言日時
        t.column :source, :text                                 # 元の内容 (html)
        t.column :created_at, :timestamp                        # （自動入力）
      end
    end

    def self.down
      drop_table :contents
    end

  end # end of class
end # end of module
