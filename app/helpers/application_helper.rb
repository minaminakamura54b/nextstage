module ApplicationHelper

  def full_title(page_title = "")
    base_title = "Ruby on Rails"
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  # 🔥 追加ここから
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      "success"
    when :error
      "danger"
    when :alert
      "warning"
    when :notice
      "info"
    when :info
      "info"
    else
      "secondary"
    end
  end

end
