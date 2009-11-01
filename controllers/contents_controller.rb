#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# 「content」のコントローラ
#

require 'time'

require 'config'
require 'controllers/http_access'
require 'models/content'


module RailForum
  class ContentsController
    attr_accessor :content

    @content    = nil
    @res        = nil

    #--------------------------------------------------
    def initialize(content=nil)
      if content
        @content = content
      else
        @content = RailForum::Content.new
      end
    end

    #--------------------------------------------------
    def url
      return @content.url
    end

    def url=(url)
      @content.url = url
    end

    #--------------------------------------------------
    def posted_at
      return @content.posted_at
    end

    def posted_at=(posted_at)
      @content.posted_at = posted_at
    end

    #--------------------------------------------------
    def get
      if !@content.url || @content.url == ''
        return nil
      end
      http = RailForum::HTTPAccess.new
      if !http.login?
        http.login
      end
      @res = http.request(@content.url, 'post')
    end

    def parse
      if !@res
        return false
      end

      @res.body.toutf8.each {|b|
        # 発言番号
        #   var Xvno='65'
        if b =~ /^.*var Xvno='[0-9]*'.*$/
          @content.content_number = b.gsub(/^.*var Xvno='([0-9]*)'.*$/, '\1').to_i
        end
        # タイトル
        #   <span class="bbssubject">タイトル</span>
        if !@content.subject
          if b =~ /^.*<span class="bbssubject">.*<\/span>.*$/
            @content.subject = b.gsub(/^.*<span class="bbssubject">(.*)<\/span>.*$/, '\1').chomp
          end
        end
        # 発言者
        #   <td class="tdbbs" colspan="2">名前 (ID) 2009-09-09 12:02:02</td>
        if b =~ /^.*<td class="tdbbs" colspan="2">.* [0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]<\/td>/
          @content.author = b.gsub(/^.*<td class="tdbbs" colspan="2">(.*) [0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]<\/td>/, '\1').chomp
        end
        # 発言日時
        #   <td class="tdbbs" colspan="2">名前 (ID) 2009-09-09 12:02:02</td>
        if !@content.posted_at
          if b =~ /^.*<td class="tdbbs" colspan="2">.* [0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]<\/td>/
            @content.posted_at = Time.parse(b.gsub(/^.*<td class="tdbbs" colspan="2">.* ([0-9][0-9][0-9][0-9]\-[0-9][0-9]\-[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9])<\/td>/, '\1'))
          end
        end
      }
      # 内容
      @content.source = @res.body
    end

    #--------------------------------------------------
    def save
      @content.save
    end

  end # end of class
end # end of module
