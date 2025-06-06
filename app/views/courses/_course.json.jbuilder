json.extract! course, :id, :title, :category, :earn_date, :school, :image_src, :image_src_thumb, :created_at, :updated_at
json.url course_url(course, format: :json)
