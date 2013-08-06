
module PIPFileUtils

	def file_exists?(page_location)
		return nil if !page_location
		FileTest.exist?(page_location)
	end

	def fetch_contents_of(file_location)
		if file_exists?(file_location)
			return File.open(file_location, "rb").read
		else
			return "<!-- file not found #{file_location} -->"
		end
	end

	def find_file_from_page(page_required)

		flash(:info, "trying to map file for uri '#{page_required}'")

		if !@site.base.nil? && @site.base != ""
			sre = Regexp.new('^' + Regexp.escape(@site.base) + '')
			pr = page_required.sub(sre, '') if !page_required.nil?
			flash(:info, "cleaned #{page_required} up to #{pr} using #{sre}")
		else
			pr = page_required
		end
			
		pr = @page.default if(pr.nil?||pr==""||pr[-1,1]=="/")
		pr = '/' + pr if pr[0] != '/'
		
		file_location_for_page = "#{APP_ROOT}/#{@files.pages.to_s.downcase}/#{pr.to_s.downcase}"
		@file_location = file_location_for_page	
		flash(:info, "file path would be: #{file_location_for_page}")

		if File.directory?(file_location_for_page)
			flash(:info, "'#{file_location_for_page} is a directory ..")
			file_location_for_page.chomp!("/")
			file_location_for_page << "/#{@page_default}"
			flash(:info, ".. tidied file name to '#{file_location_for_page}")
		end

		if file_exists?(file_location_for_page)
			return file_location_for_page
		else
			@page.endings.each { |ending|
				file_to_check = "#{file_location_for_page}.#{ending}"
				flash(:info, "checking file : #{file_to_check}")
				if file_exists?(file_to_check)
					return file_to_check
				end
			}
		end

		file404 = "#{APP_ROOT}/#{@files.not_found}"

		return file404 if file_exists?(file404)
			
		return nil

	end

end