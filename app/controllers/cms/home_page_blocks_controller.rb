class Cms::HomePageBlocksController < ApplicationController

  include ShowsHelper
  layout 'admin'
  attr_reader :action_nav
  helper CW::ActionNav::View

  skip_filter :enable_admin_layout_preview
  skip_filter :enable_admin_preview_at_time


  require_post_method_for :create, :destroy, :move_block_order_down, :move_block_order_up, :move_block_order_top, :move_block_order_bottom, :move_block_to_location, :show, :hide, :update
  hide_action :block_pagination

  def block_pagination
    @pagination = CW::Pagination::Model::ActiveRecord.new( self, 'HomePageBlock', CW::SortOrder.desc('acts_as_ordered_order'), {}, Setting['vms-protected-items-per-page'].value_typed )
  end

  # List the order of the episodes for the show ID. If the ID is zero, it's for the home page.
  def index
    block_pagination
    respond_to do |format|
      format.html {
        @action_nav = CW::ActionNav::Controller::Base.new.section('Change') {|s|
          s.link 'add show episode ordering', { :action => 'new', :type => 'HomePageBlockShowDl' }, { :title => 'Add a Show DL Episode ordered block to the home page' }
          s.link 'add show filtered ordering', { :action => 'new', :type => 'HomePageBlockFiltered' }, { :title => 'Add a block filtered by show id and order to the home page' }
        }
        render :action => 'index'
      }
    end
  end

  def new
    case params[:type]
      when 'HomePageBlockShowDl'
        @hpb = HomePageBlockShowDl.new
      when 'HomePageBlockFiltered'
        @hpb = HomePageBlockFiltered.new
    else
      @hpb = HomePageBlock.new
    end
  end

  def create
    @hpb = HomePageBlock.new
    @hpb.visible = params[:hpb]['visible']
    @hpb.machine_name = params[:hpb]['machine_name']
    @hpb.block_style = params[:hpb]['block_style']
    case params[:type]
      when 'HomePageBlockShowDl'
        @hpb.type = params[:type]
      when 'HomePageBlockFiltered'
        @hpb.type = params[:type]
      else
        raise 'Unrecognized HomePageBlock type: ' + params[:type]
    end
    if @hpb.save
      @hpb = HomePageBlock.find(@hpb.id)
      case params[:type]
        when 'HomePageBlockShowDl'
          @hpb.show_id = params[:hpb]['show_id']
        when 'HomePageBlockFiltered'
          @hpb.show_id = params[:hpb]['show_id']
          @hpb.order_by_string = params[:hpb]['order_by_string']
        else
          raise 'Unrecognized HomePageBlock type: ' + params[:type]
      end
      @hpb.save
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @hpb = HomePageBlock.find(params[:id])
    render :action => 'edit'
  end

  def update
    @hpb = HomePageBlock.find(params[:id])
    @hpb.visible = params[:hpb]['visible']
    @hpb.machine_name = params[:hpb]['machine_name']
    @hpb.block_style = params[:hpb]['block_style']
    case @hpb.class.name
      when 'HomePageBlockShowDl'
        @hpb.show_id = params[:hpb]['show_id']
      when 'HomePageBlockFiltered'
        @hpb.show_id = params[:hpb]['show_id']
        @hpb.order_by_string = params[:hpb]['order_by_string']
      else
        raise 'Unrecognized HomePageBlock type: ' + params[:type]
    end
    if @hpb.save
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end




  def move_block_order_down
    @hpb = HomePageBlock.find(params[:id]).becomes(HomePageBlock)
    block_pagination
    @hpb.move_order_up
    flash[:msg] = 'Block moved down'
    redirect_to :action => 'index', :page => @pagination.page_number_of_item(@hpb)
  end

  def move_block_order_up
    @hpb = HomePageBlock.find(params[:id]).becomes(HomePageBlock)
    block_pagination
    @hpb.move_order_down
    flash[:msg] = 'Block moved up'
    redirect_to :action => 'index', :page => @pagination.page_number_of_item(@hpb)
  end

  def move_block_to_top
    @hpb = HomePageBlock.find(params[:id]).becomes(HomePageBlock)
    block_pagination
    @hpb.move_order_to( :last )
    flash[:msg] = 'Block moved to the top'
    redirect_to :action => 'index', :page => @pagination.page_number_of_item(@hpb)
  end

  def move_block_to_bottom
    @hpb = HomePageBlock.find(params[:id]).becomes(HomePageBlock)
    block_pagination
    @hpb.move_order_to( :first )
    flash[:msg] = 'Block moved to the bottom'
    redirect_to :action => 'index', :page => @pagination.page_number_of_item(@hpb)
  end

  def move_block_to_location
    @hpb = HomePageBlock.find(params[:id]).becomes(HomePageBlock)
    block_pagination
    @hpb.move_order_to( HomePageBlock.count - params[:location].to_i )
    flash[:msg] = 'Block moved'
    redirect_to :action => 'index', :page => @pagination.page_number_of_item(@hpb)
  end


  def destroy
    @hpb = HomePageBlock.find(params[:id]).becomes(HomePageBlock)
    block_pagination
    pgnum = @pagination.page_number_of_item(@hpb)
    @hpb.destroy
    flash[:msg] = "Removed block #{@hpb.id}"
    redirect_to :action => 'index', :page => pgnum
  end


  def hide
    @hpb = HomePageBlock.find(params[:id])
    block_pagination
    pgnum = @pagination.page_number_of_item(@hpb)
    @hpb.visible = false
    @hpb.save
    flash[:msg] = "Block now hidden"
    redirect_to :action => 'index', :page => pgnum
  end

  def show
    @hpb = HomePageBlock.find(params[:id])
    block_pagination
    pgnum = @pagination.page_number_of_item(@hpb)
    @hpb.visible = true
    @hpb.save
    flash[:msg] = "Block now visible"
    redirect_to :action => 'index', :page => pgnum
  end



  
  
end
