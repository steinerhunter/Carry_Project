module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "sendd.me"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def location
    if params[:location].blank?
      if Rails.env.test? || Rails.env.development?
        @location ||= Geocoder.search("50.78.167.161").first
      else
        @location ||= request.location
      end
    else
      params[:location].each {|l| l = l.to_i } if params[:location].is_a? Array
      @location ||= Geocoder.search(params[:location]).first
      @location
    end
  end
end
