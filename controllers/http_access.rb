#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forumへのhttpアクセス
#

require 'net/http'
require 'net/https'
require 'uri'

require 'models/account'


module RailForum
  class HTTPAccess
    @@cookie    = nil
    @@account   = nil

    #--------------------------------------------------
    def initialize
      if !@@account
        @@account = RailForum::Account.new(RailForum::Config[:RailForumHome] + "/" + RailForum::Config[:YamlFile])
        if !@@account.exist?
          while !@@account.create
          end
        end
      end
    end

    #--------------------------------------------------
    def login
      # すでにログインしている時は何もしない
      if login?
        return true
      end

      # loginする
      res = request(RailForum::Config[:LoginURL], 'post',
                         "id=#{@@account.user}&pw=#{@@account.password}&act_login_do= ")
      # ログイン失敗？
      #  「meta http-equiv="refresh"」があればlogin成功
      if res.body !~ /meta http-equiv=\"refresh\"/
        print "Login failed.\n"
        return nil
      end

      # cookieを格納
      @@cookie = res['set-cookie'].split(',').join(';')
      return true
    end

    #--------------------------------------------------
    def logout
      # すでにログアウトしているときは何もしない
      if !login?
        return true
      end

      # logoutする
      res = request(RailForum::Config[:LogoutURL], 'get',
                         "act_logout= ")
      # ログアウト失敗？
      #  「meta http-equiv="refresh"」があればlogout成功
      if res.body =~ /meta http-equiv=\"refresh\"/
        print "Logout failed.\n"
        return nil
      end

      # cookieをクリア
      @@cookie = nil
      return true
    end

    #--------------------------------------------------
    def request(url, method, body=nil)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      # SSL
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if method == 'post'
        req = Net::HTTP::Post.new(uri.path)
      elsif method == 'get'
        req = Net::HTTP::Get.new(uri.path)
      else # 変な場合は何もしない
        return nil
      end
      if !body
        body = uri.query
      end
      req.body = URI.encode(body)
      req['Content-Length'] = req.body.size
      if @@cookie
        req['Cookie'] = @@cookie
      end

      res = http.request(req)
      return res
    end

    #--------------------------------------------------
    def login?
      if !@@cookie
        return false
      end
      return true
    end

  end # end of class Base
end # end of module
