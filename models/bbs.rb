#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forumの1つの掲示板
#

require 'activerecord'

module RailForum
  class BBS < ActiveRecord::Base
    has_many :contents
    validates_presence_of :bbs_number, :rss_url, :subject, :last_post_at
  end # end of class
end # end of module
