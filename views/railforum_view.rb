#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forum
#   表示モジュール
#

require 'rubygems'
require 'nkf'
require 'hpricot'

require 'railforum'


module RailForum
  class RailForumView
    @account    = nil
    @read_point = nil

    #--------------------------------------------------
    def initialize(read)
      # 巡回する掲示板を取得
      @account = RailForum::Account.new(RailForum::Config[:RailForumHome] +
                                      "/" + RailForum::Config[:YamlFile])
      if !@account.exist?
        while !@account.create
        end
      end

      @read_point = read
      # 既読ポインタ指定がない場合は全掲示版を読む
      if !@read_point || @read_point.length == 0
        @read_point = {}
        @account.bbs.each do |bbs_num|
          @read_point[bbs_num] = -1
        end
      end
    end

    #--------------------------------------------------
    def contents
      @read_point.each do |read|
        # 未読コンテンツの取得
        bbs, contents = get_unread_contents(read[0])
        if !bbs || !contents
          next
        end


        print "\n######################################################################\n"
        print "     【#{bbs.bbs_number}】 #{bbs.subject}\n"
        print "######################################################################\n\n"
        if contents.length <= 0
          print "\t未読なし\n\n"
        end

        # 各掲示板の記事を処理
        contents.each do |content|
          # hpricotで解析
          doc = Hpricot.parse(content.source)
          #     # 発言者
          #     author = doc.search("html/body/div[2]/tr[1]/td[1]").inner_html.split(/\s+/)[0]
          #     # 発言日
          #     posted_on = doc.search("html/body/div[2]/tr[1]/td[1]").inner_html.split(/\s+/)[1]
          #     # 発言時刻
          #     posted_at = doc.search("html/body/div[2]/tr[1]/td[1]").inner_html.split(/\s+/)[2]
          # 内容
          text = ((((doc/:html/:body/:table)[2]/:tr)[0]/:td)[0]/:div)[0].inner_html
          ### <br>または<br /> → 改行
          ### <.*> → 削除
          text = text.gsub(/<br[\s\/]*>/, "\n").gsub(/<[^>]+>/, '')
          ### &gt; → '>'
          ### &lt; → '<'
          text = text.gsub('&gt;', '>').gsub('&lt;', '<')
          ### &nbsp; → ' '
          ### &amp; → '&'
          text = text.gsub('&nbsp;', ' ').gsub('&amp;', '&')

          print "======================================================================\n"
          #     print "BBS No.    : " + NKF.nkf("-wLu", "#{bbs.bbs_number}\n")
          #     print "BBS Subject: " + NKF.nkf("-wLu", "#{bbs.subject}\n")
          #     print "------------------------------\n"
          print "No.        : " + NKF.nkf("-wLu", "#{content.content_number}\n")
          print "Author     : " + NKF.nkf("-wLu", "#{content.author}\n")
          print "Date       : " + NKF.nkf("-wLu", "#{content.posted_at.strftime '%Y/%m/%d %H:%M'}\n");
          print "Subject    : " + NKF.nkf("-wLu", "#{content.subject}\n")
          print "----------------------------------------------------------------------\n"
          print NKF.nkf("-wLu", "#{text}\n\n")
        end

        # 既読番号を更新
        bbs.read_point = bbs.contents.last.content_number
        bbs.save
      end
    end

    #--------------------------------------------------
    def subjects
      @read_point.each do |read|
        # 未読コンテンツの取得
        bbs, contents = get_unread_contents(read[0])
        if !bbs || !contents
          next
        end

        print "\n######################################################################\n"
        print "     【#{bbs.bbs_number}】 #{bbs.subject}\n"
        print "######################################################################\n\n"
        if contents.length <= 0
          print "\t未読なし\n\n"
        end

        # 各掲示板の記事を処理
        contents.each do |content|
          printf "%5d ", content.content_number
          print NKF.nkf("-wLu", "#{content.subject}\n")
        end
      end
    end


    #==================================================
    private
    def get_unread_contents(bbs_num)
      # 掲示板番号でDBから情報取得
      bbs = RailForum::BBS.find(:first, :conditions => ["bbs_number=#{bbs_num}"])
      if !bbs
        print "\nIgnoring bbs##{bbs_num}.\n"
        return nil
      end

      # 指定がない場合は既読ポインタがマイナスになっているのでDBの値を使用
      if !@read_point || @read_point[bbs_num] < 0
        @read_point[bbs_num] = bbs.read_point.to_i
      end

      # 既読番号より大きい番号のコンテンツのみ取得
      contents = RailForum::Content.find(:all,
                                         :conditions => ["bbs_id=#{bbs.id} AND content_number>#{@read_point[bbs_num]}"],
                                         :order => ["posted_at"])

      return [bbs, contents]
    end

  end # end of class
end # end of module
