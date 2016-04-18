class TagsController < ApplicationController
  protect_from_forgery except: :update_push

  # GET /tags
  # GET /tags.json
  def index
    @tags = Tag.all
  end

  # GET /tags/update_get
  # GET /tags/update_get.json
  def update_get
    @datetime = params[:lastdt]
    if @datetime.blank?
      @tags = Tag.all
    else
      @tags = Tag.update_get @datetime
    end
  end
  
  # POST /tags/update_push
  # POST /tags/update_push.json
  # 想定するPOSTデータは以下
  # update_tags=[{"photo_id":1, "member_id":1}]
  def update_push
  
    # POSTのjsonを受け取る
    update_tags = JSON.parse(params["update_tags"])
    for update_tag in update_tags
      # 既存レコードを検索
      @tag = Tag.find_by_photo(update_tag["photo_id"]).find_by_member(update_tag["member_id"])
      if @tag.blank?
        # 存在しない場合レコードを追加する
        @tag = Tag.create :photo_id=>update_tag["photo_id"], :member_id=>update_tag["member_id"]
      else
        # 存在した場合カウントをインクリメントする
        # (タグの信憑度が下がった場合利用を検討する)
        @tag[0].increment!(:count)
      end
    end
    
    head 200
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tag_params
      params.require(:tag).permit(:photo_id, :member_id, :count)
      params.require(:update_tags)
    end
end
