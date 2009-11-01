#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forumのアカウント
#

require 'rubygems'
# gem 'highline', "1.2.9"

require 'highline'
require 'base64'


module RailForum
  class Account
    attr_reader :user, :password, :bbs

    @user       = ""
    @password   = ""
    @bbs        = []
    @yml_file   = nil

    #--------------------------------------------------
    def initialize(yml_file)
      @yml_file = yml_file

      # yamlがない場合は即return
      if !exist?
        return
      end

      # yamlから情報を取得する
      File.open(@yml_file) do |io|
        YAML.load_documents(io) do |y|
          # ユーザ名
          if defined? y['user']
            @user = y['user']
          end
          # パスワード
          if defined? y['pass']
            @password = Base64.decode64(y['pass'])
          end
          # 巡回掲示板
          if defined? y['bbs']
            @bbs = y['bbs']
          end
        end
      end
    end

    #--------------------------------------------------
    def create
      print "Please enter your id and password.\n"
      user = HighLine.new.ask('ID: ')
      pass = Base64.encode64(HighLine.new.ask('Password: ') {|q| q.echo = '*' })
      bbs_str = HighLine.new.ask('BBS (separate by \',\' or \' \'): ').split(/[ ,]+/)

      if !valid?(user, pass, bbs_str)
        print "Invalid id, password or bbs.\n"
        return false
      end

      yml = File.open(@yml_file, 'w')
      yml.puts "user: #{user}"
      yml.puts "pass: #{pass}"
      if bbs_str != []
        yml.puts "bbs:"
        bbs = []
        bbs_str.each {|b|
          bbs << b.to_i
          yml.puts " - #{b.to_i}"
        }
      end
      yml.close

      @user     = user
      @password = pass
      @bbs      = bbs

      return true
    end

    #--------------------------------------------------
    def valid?(user=@user, pass=@password, bbs=@bbs)
      # パスワード、ユーザ名は必須
      if (user == "" || pass == "")
        return false
      end

      # bbsは数字
      bbs.each {|b|
        if (b != "" && b !~ /^[0-9]+$/)
          return false
        end
      }

      return true
    end

    #--------------------------------------------------
    def exist?
      # ファイルがない場合はfalse
      if !FileTest.exist?(@yml_file)
        return false
      end
      # パスは存在するけどファイルじゃない場合はfalse
      if !FileTest::file?(@yml_file)
        return false
      end
      return true
    end

  end # end of class
end # end of module
