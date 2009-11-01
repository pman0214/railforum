#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'railforum'



task :default => [:db_migrate]


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
