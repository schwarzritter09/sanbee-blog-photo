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
  # update_tags=[{"photo_id":1, "member_id":1, "push_mode":"add"}]
  def update_push
  
    # POSTのjsonを受け取る
    update_tags = JSON.parse(params["update_tags"])
    for update_tag in update_tags
      # 既存レコードを検索
      @tag = Tag.find_by_photo(update_tag["photo_id"]).find_by_member(update_tag["member_id"]).where("count > 0")
      if @tag.blank? && "add"==update_tag["mode"]
        # 存在しない場合かつカウントモードがaddの場合、レコードを追加する
        @tag = Tag.create :photo_id=>update_tag["photo_id"], :member_id=>update_tag["member_id"], :count=>1
      else
        # 存在した場合、カウントモードに応じてインクリメント/デクリメントする。
        # カウントモードが不正な場合何もしない
        if "add"==update_tag["mode"]
          @tag[0].increment!(:count)
        elsif "del"==update_tag["mode"] && @tag[0].count >= 0
          # マイナスにはしない
          @tag[0].decrement!(:count)
        end
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
    params.require(:tag).permit(:photo_id, :member_id, :mode)
    params.require(:update_tags)
  end
end