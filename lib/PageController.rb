APP_ROOT   = "#{File.dirname(__FILE__)}/.." unless defined?(APP_ROOT)
$LOAD_PATH << "#{APP_ROOT}/lib"

require 'yaml'
require 'cgi'
require 'erb'

require 'PIPViewUtils'
require 'PIPPageUtils'
require 'PIPFileUtils'

class PageController

	include PIPViewUtils
	include PIPPageUtils
	include PIPFileUtils

	def initialize(root)
		@root = root
		settings
		#@settings = get_settings
		@page_required = ENV['REQUEST_URI']
		@default_app_settings = {
			:site_name => "Default Site Name"
		}
		
	end

	def build_page
		file_required = find_file_from_page(@page_required)
    	file_required ? render_file(file_required) : render("<h1>Error</h1><p>Set-up error - url #{@page_required} could not be mapped.</p>")
	end

	private

	def settings
		settings_file = "#{@root}/config/settings.yml"
		if FileTest.exist?(settings_file)
			yml = YAML::load_file(settings_file)
			yml.each_pair do |section, keys|
				instance_variable_set("@#{section}".to_sym, Object.new)
				keys.each_pair do |setting,value|
					instance_variable_get("@#{section}".to_sym).class.module_eval { attr_accessor "#{setting}".to_sym }
					instance_variable_get("@#{section}".to_sym).send("#{setting}=", value)
				end
			end
			flash(:info, "Site Data : #{@site.inspect}<br/>")
		else
			render "Can't find config file #{settings_file}"
		end
	end

	def default_for(app_setting_name)
		@default_app_settings[app_setting_name]
	end

	def debug_page
		debug = ""
		debug << "<h1>Debug</h1>"
		debug << "<p>#{cgi.params.inspect}</p>"
		debug << "<p>Uri = " + "#{ENV['REQUEST_URI']}</p>"
		debug << "<p>Site Name = #{@site_name}</p>"
		render(debug)
	end

	def render_file(page_fragment_file_path)

		@page.class.module_eval { attr_accessor :title }

		if page_fragment_file_path =~ /\.rhtml$/
			input = File.read(page_fragment_file_path)
			page_content =  ERB.new(input).result(binding)
			@page.title  = @page.title_prefix + (extract_title(page_content) || @page.title_default)
		else
			fragment_content = fetch_contents_of(page_fragment_file_path)
			page_content     = clean_page(fragment_content)
			@page.title      = @page.title_prefix + (extract_title(page_content) || @page.title_default)
		end
		render page_content
	end

	def render(content, layout=nil)
		@page_content = content
		cgi = CGI.new("html4")
		if layout
			decorater = "#{APP_ROOT}/#{@files.layouts}/#{layout}.rhtml"
		else
			decorater = "#{APP_ROOT}/#{@files.layouts}/#{@page.layout_default}"
		end
		input = File.read(decorater)
		flash(:info, "rendering layout: #{decorater}")
		output = ERB.new(input).result(binding)
		if defined? @test_mode
			puts cgi.inspect
		else
			cgi.print cgi.header
			cgi.print output
		end
	end

end