#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#
require File.join(Rails.root, 'lib', 'stream', 'followed_tag')

class TagFollowingsController < ApplicationController
  before_filter :authenticate_user!

  def index
    default_stream_action(Stream::FollowedTag)
  end

  # POST /tag_followings
  # POST /tag_followings.xml
  def create
    name_normalized = ActsAsTaggableOn::Tag.normalize(params['name'])
    @tag = ActsAsTaggableOn::Tag.find_or_create_by_name(name_normalized)
    @tag_following = current_user.tag_followings.new(:tag_id => @tag.id)

    respond(@tag_following.save, 'create', :back)
  end

  # DELETE /tag_followings/1
  # DELETE /tag_followings/1.xml
  def destroy
    @tag = ActsAsTaggableOn::Tag.find_by_name(params[:name])
    @tag_following = current_user.tag_followings.where(:tag_id => @tag.id).first

    respond(@tag_following && @tag_following.destroy, 'destroy', tag_path(:name => params[:name]))
  end

  def respond(success, action, destination)
    msg = I18n.t('tag_followings.' + action + "." + (success ? 'success' : 'failure'), :name => @tag.name)
    
    respond_to do |format|
      format.html { 
        flash[(success ? :notice : :error)] = msg
        redirect_to destination
      }
      format.js {
        @data = { :action => action, :success => success ? '1' : '0', :msg => msg }
        render 'tags/update'
      }
    end
  end

  def create_multiple
    if params[:tags].present?
      params[:tags].split(",").each do |name|
        name_normalized = ActsAsTaggableOn::Tag.normalize(name)
        @tag = ActsAsTaggableOn::Tag.find_or_create_by_name(name_normalized)
        @tag_following = current_user.tag_followings.create(:tag_id => @tag.id)
      end
    end
    redirect_to multi_path
  end
end
