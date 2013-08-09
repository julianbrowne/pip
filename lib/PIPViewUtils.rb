
module PIPViewUtils

	def stylesheet_link_tag(stylesheet_name)
		"<link type=\"text/css\" rel=\"stylesheet\" href=\"#{@urls.stylesheets}/#{stylesheet_name}.css\">"
	end

	def image_link_tag(image_name, border=0)
		"<img src=\"#{@urls.images}/#{image_name}\" border=\"#{border}\">"
	end

	def javascript_link_tag(script_name)
		"<script src=\"#{@urls.scripts}/#{script_name}.js\"></script>"
	end

	def flash(message_class, message_text)
		@flash ||= {}
		@flash[message_class] ||= []
		@flash[message_class] << "<li style='font-family: helvetica; margin-left: 20px; color: #FF6633;'>" + message_text + "</li>"
	end

	def layout(template)
		@layout = template
	end

end
