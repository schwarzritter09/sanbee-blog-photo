module PhotosHelper

  def search_panel
    
    searchMemberMap = {}
    if params[:photo_search].present? && params[:photo_search][:member_id].present?
      params[:photo_search][:member_id].each do |m|
        searchMemberMap[m.to_s] = m
      end
    end
    p searchMemberMap

    unitMap = {}
    unitMap[2] = "アメフラっシ"
    unitMap[7] = "その他"
    unitMap[4] = "3Bjr"

    content_tag :div, :class=>"panel-group", :id=>"unit" do
      unitMap.each do |id, unit|
        concat ( content_tag :div, :class=>"panel panel-default" do
          concat ( content_tag :div, :class=>"panel-heading" do
            concat ( content_tag :h4, :class=>"panel-title" do
              concat ( content_tag :a, :data=>{:toggle=>"collapse", :parent=>"#unit"}, :href=>"#area#{id}" do
                concat unit
              end)
            end)
          end)
        end)
        concat ( content_tag :div, :id=>"area#{id}", :class=>"panel-body collapse" do
          concat search_buttons id, searchMemberMap
        end)
      end
      concat ( content_tag :div, :class=>"panel panel-default" do
        concat ( content_tag :div, :class=>"panel-heading" do
          concat ( content_tag :h4, :class=>"panel-title" do
            concat ( content_tag :a, :data=>{:toggle=>"collapse", :parent=>"#unit"}, :href=>"#area0" do
              concat "タグ無し(他の条件より優先します)"
            end)
          end)
        end)
      end)
      concat ( content_tag :div, :id=>"area0", :class=>"panel-body collapse" do
        concat ( content_tag :div, :class=>"btn-group", :data=>{:toggle=>"buttons"} do
          inActive = "active" if params[:photo_search].present? && params[:photo_search][:nothingtag].present?
          concat ( content_tag :label, :class=>"btn btn-lg btn-default member-button #{inActive}", :data=>{:member_id=>"0"} do
            concat ( content_tag :input, :type=>"checkbox", :autocomplete=>"off", :name=>"photo_search[nothingtag]", :value=>"0" do
              concat "タグ無し"
            end)
          end)
        end)
      end)
    end
  end

  def search_buttons(unit_id, searchMemberMap)
    content_tag :div, :class=>"btn-group", :data=>{:toggle=>"buttons"} do
      Member.where(unit_id: unit_id).each do |m|
        inActive = "active" if searchMemberMap[m.id.to_s].present?
        concat ( content_tag :label, :class=>"btn btn-lg btn-default member-button #{inActive}", :data=>{:member_id=>m.id} do
          concat ( content_tag :input, :type=>"checkbox", :autocomplete=>"off", :name=>"photo_search[member_id][]", :value=>m.id do
            m.name
          end)
        end)
      end
    end
  end

  def tag_panel(photo)

    unitMap = {}
    unitMap[2] = "アメフラっシ"
    unitMap[7] = "その他"
    unitMap[4] = "3Bjr"

    content_tag :div, :class=>"panel-group", :id=>"tag" do
      unitMap.each do |id, unit|
        concat ( content_tag :div, :class=>"panel panel-default" do
          concat ( content_tag :div, :class=>"panel-heading" do
            concat ( content_tag :h4, :class=>"panel-title" do
              concat ( content_tag :a, :data=>{:toggle=>"collapse", :parent=>"#tag"}, :href=>"#area#{id}" do
                concat unit
              end)
            end)
          end)
        end)
        collapseState = "collapse"
        if id == 2 || id == 7
          collapseState = "collapse in"
        end
        concat ( content_tag :div, :id=>"area#{id}", :class=>"panel-body #{collapseState}" do
          concat tag_buttons @photo, id
        end)
      end
    end
  end

  def tag_buttons(photo, unit_id)

    tags = {}
    photo.tags.each do |t|
      tags[t.member_id] = t
    end

    content_tag :div, :class=>"btn-group", :data=>{:toggle=>"buttons"} do
      Member.where(unit_id: unit_id).each do |m|
        if !tags[m.id].nil? && !tags[m.id].count.nil? && tags[m.id].count > 0
          concat ( content_tag :label, :class=>"btn btn-lg btn-default tag-button active", :data=>{:photo_id =>photo.id, :member_id=>m.id} do
            concat ( content_tag :input, :type=>"checkbox", :autocomplete=>"off", :checked=>true do
              m.name
            end)
          end)
        else
          concat ( content_tag :label, :class=>"btn btn-lg btn-default tag-button", :data=>{:photo_id =>photo.id, :member_id=>m.id} do
            concat ( content_tag :input, :type=>"checkbox", :autocomplete=>"off" do
              m.name
            end)
          end)
        end
      end
    end
  end
end
