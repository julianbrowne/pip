
module PIPPageUtils

	def clean_page(page_content,debug=false)
		debug ? tag = "<!-- removed tag -->" : tag = ""
		page_content.sub!(/<!doctype[^>]*>/i, tag)
		page_content.sub!(/<html[^>]*>/i, tag)
		page_content.sub!(/<body[^>]*>/i, tag)
		page_content.sub!(/<\/body>/i, tag)
		page_content.sub!(/<\/html>/i, tag)		
		page_content.gsub!(/<head>(?:.|\n|\r)+?<\/head>/i, tag)
		page_content.gsub!(/\s*(\n|\r)/, "\r")
		page_content.gsub!(/\.pdf"/, '.pdf" target="_blank" title="Adobe PDF Document" class="link_pdf"')
		return page_content
	end

	def extract_title(page_content)

		title_regex = Regexp.new("/<title>(\s*(.*)\s*)<\/title>/iu".encode("UTF-8"),0)

		if match = page_content.match(title_regex)
			title = match[0]
			title.sub!(/<title>/i,"")
			title.sub!(/<\/title>/i,"")
			return "#{title}"
		else
			return nil
		end
	end

end