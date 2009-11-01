#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#
# Rail Forum BBSの1つの発言
#

require 'activerecord'

module RailForum
  class Content < ActiveRecord::Base
    belongs_to :bbs
    validates_presence_of :content_number, :url, :subject
    validates_presence_of :author, :posted_at, :source
  end # end of class
end # end of module
