#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# 初期化処理
#

require 'railforum'
require 'activerecord'


module RailForum
  class Init
    def self.init
      db_file = RailForum::Config[:RailForumHome] + "/railforum.db"
      ActiveRecord::Base.establish_connection(
                                              :adapter => 'sqlite3',
                                              :database  => db_file
                                              )
    end

  end # end of class
end # end of module
