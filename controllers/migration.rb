#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# DBのmigration
#

require 'railforum'
require 'migrate'


module RailForum
  class Migration

    #--------------------------------------------------
    def self.up
      # データを保存するディレクトリがなければ作成
      if FileTest.exist?(RailForum::Config[:RailForumHome])
        if FileTest::directory?(RailForum::Config[:RailForumHome])
        else
          print "#{RailForum::Config[:RailForumHome]} is not a directory\n"
          exit
        end
      else
        Dir.mkdir(RailForum::Config[:RailForumHome])
      end

      # DBファイルがなければ作成
      db_file = RailForum::Config[:RailForumHome] + "/railforum.db"
      if FileTest.exist?(db_file)
        if FileTest::file?(db_file)
        else
          print "#{db_file} is not a file\n"
          exit
        end
      else
        RailForum::BBSMigration.migrate(:up)
        RailForum::ContentMigration.migrate(:up)
      end
    end

    #--------------------------------------------------
    def self.down
      RailForum::BBSMigration.migrate(:down)
      RailForum::ContentMigration.migrate(:down)
    end
        
  end # end of class
end # end of module
