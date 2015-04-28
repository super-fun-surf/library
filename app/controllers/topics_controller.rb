class TopicsController < ApplicationController
  before_action :set_topic, only: [:show, :edit, :update, :destroy]

  def index
    if params[:set_locale]
      redirect_to topics_path(locale: params[:set_locale])
    else
      @topics = Topic.all
    end

    #@topics = Topic.search(params[:search])
    #@topics = Topic.all.where(language =  '1')
    #@topics = Topic.where(:language => '1')
    #@homeless_topics = Topic.find_by_parents(nil)
  end

  def show
    @topic = Topic.find(params[:id])
    @topics = Topic.all
    if params[:publication_id].present?
      @show_pub = Pub.find(params[:publication_id])
    end
    if @topic.parents.present?
      @temp_topic = @topic.parents.first.id
    end
  end


  def new
    @topic = Topic.new
    @topics = Topic.all
    if params[:parent_id].present?
      @parent_topic = Topic.find(params[:parent_id])
    end
    if params[:original_id].present?
      @original_topic = Topic.find(params[:original_id])
    end

  end


  def create
    @topic = Topic.new(topic_params)
    if topic_params[:major_update].present?
      @topic.version=1
    end
    if params[:parent_id].present?
      @parent_topic = Topic.find(params[:parent_id])
    end
    if params[:original_id].present?
      @original_topic = Topic.find(params[:original_id])
    end
    if @topic.save
      if @parent_topic.present?
        @topic.make_parent(@parent_topic)
      end
      if @original_topic.present?
        @topic.translation_of(@original_topic)
      end

      # its saved and now we create the translations
      #if !@topic.all_translations_exist?


      # NOW CREATE THE TRANSLATIONS
      @original_topic=@topic

      if @original_topic.language != 'na'
      $av_langs_hash.each do |k,v| unless k == 'na' || k == @original_topic.language
                                     if @original_topic.parents.first.id < 4
                                       @parent_topic=@topic.parents.first
                                     else
                                       @parent_topic = @original_topic.parents.first.translations.find_by_language(k)
                                     end


                                     #if !@original_topic.translations.include?(k)
                                       @topic = Topic.new(language: k,
                                                          placeholder: TRUE,
                                                          category: @original_topic.category,
                                                          name: nil,
                                                          skill: 0)
                                       if @topic.save
                                         @topic.make_parent(@parent_topic)
                                         @topic.translation_of(@original_topic)
                                         #flash[:info] = "New Spanish Topic Created."
                                       end
                                     #end
                                   end
      end
      end

      flash[:info] = "New Topic Created."
      # now create the categories
      if params[:create_cat_1] == 1
        if !@original_topic.kids.include?(category: 1)
          breakpoint
        end
      end


      redirect_to edit_topic_path(@original_topic)
    else
      render 'new'
    end
  end



  def edit
    @topic = Topic.find(params[:id])
    @topics = Topic.all

  end

  def update
    @topic = Topic.find(params[:id])
    if params[:parent_id].present?
      @parent_topic = Topic.find(params[:parent_id])
    end

   if topic_params[:major_update] == 1
     @topic.version+=1
   end

    if @topic.update_attributes(topic_params)
      flash[:success] = "Topic updated"
      redirect_to edit_topic_path(@topic)
    else
      render 'edit'
    end
  end


  def destroy
    Topic.find(params[:id]).destroy
    flash[:success] = "Topic deleted"
    redirect_to topics_url
  end




  private

  def topic_params
    params.require(:topic).permit(:name,
                                  :language,
                                  :category,
                                  :skill,
                                  :main_content,
                                  :parent_id,
                                  :kid_id,
                                  :publication_id,
                                  :original_id,
                                  :icon,
                                  :set_locale,
                                  :locale,
                                  :translation,
                                  :placeholder,
                                  :growing,
                                  :major_update,
                                  :create_cat_1,
                                  :create_cat_2,
                                  :create_cat_3,
                                  :create_cat_4)

  end

  def set_topic
    @topic = Topic.find(params[:id])
  end


end
