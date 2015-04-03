class Admin::EventsController < ApplicationController
  def index
    @events = Events.all
  end

  def show
    @events = Events.find(params[:id])
  end

  def new
    @events = Events.new
  end

  def create
    @events = Events.new(params[:events])
    if @events.save
      redirect_to [:admin, @events], :notice => "Successfully created events."
    else
      render :action => 'new'
    end
  end

  def edit
    @events = Events.find(params[:id])
  end

  def update
    @events = Events.find(params[:id])
    if @events.update_attributes(params[:events])
      redirect_to [:admin, @events], :notice  => "Successfully updated events."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @events = Events.find(params[:id])
    @events.destroy
    redirect_to admin_events_url, :notice => "Successfully destroyed events."
  end
end
