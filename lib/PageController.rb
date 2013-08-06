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

		@page.class.module_eval { attr_accessor :title }
		@page.class.module_eval { attr_accessor :content }
		@page.class.module_eval { attr_accessor :layout }
		@page.class.module_eval { attr_accessor :uri }

		@page.uri = ENV['REQUEST_URI']
		@page.title = @page.title_default
		
	end

	def build_page
		file_on_disk = find_file_from_page(@page.uri)
		if file_on_disk.nil?
			#cgi.header "status" => "NOT_FOUND"
			render("<h1>Error</h1><p>Set-up error - url #{@page.uri} could not be mapped.</p><p>#{@flash}</p>")
		else
			flash(:debug, "Found file #{file_on_disk}")
			render_file(file_on_disk)
		end
	end

	private

	def settings
		settings_file = "#{@root}/config/settings.yml"
		YAML::ENGINE.yamler = 'psych'
		if FileTest.exist?(settings_file)
			yml = YAML::load_file(settings_file)
			yml.each_pair do |section, keys|
				instance_variable_set("@#{section}".to_sym, Object.new)
				keys.each_pair do |setting,value|
					instance_variable_get("@#{section}".to_sym).class.module_eval { attr_accessor "#{setting}".to_sym }
					instance_variable_get("@#{section}".to_sym).send("#{setting}=", value)
				end
			end
			flash(:info, "@site => <code>#{CGI::escapeHTML(@site.inspect.to_s)}</code>")
			flash(:info, "@page => <code>#{CGI::escapeHTML(@page.inspect.to_s)}</code>")
		else
			render "Can't find config file #{settings_file}"
		end
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
		if page_fragment_file_path =~ /\.rhtml$/
			input = File.read(page_fragment_file_path)
			page_content =  ERB.new(input).result(binding)
			@page.title  = @page.title_prefix + (extract_title(page_content) || @page.title_default)
		else
			fragment = fetch_contents_of(page_fragment_file_path)
			page_content = clean_page(fragment)
			@page.title      = @page.title_prefix + (extract_title(page_content) || @page.title_default)
		end
		render_templated_content page_content
	end

	def render(content)
		@page.content = content
		flash(:info, "rendering layout-free content")
		output = ERB.new(@page.content).result(binding)
		deliver(output)
	end

	def render_templated_content(content, template=nil)
		@page.content = content
		@page.layout  = template.nil? ? "#{APP_ROOT}/#{@files.layouts}/#{@page.layout_default}" : "#{APP_ROOT}/#{@files.layouts}/#{template}.rhtml"
		outline = File.read(@page.layout)
		flash(:info, "rendering content with layout: #{@page.layout}")
		output = ERB.new(outline).result(binding)
		deliver(output)
	end

	def deliver(content)
		cgi = CGI.new("html4")
		cgi.print cgi.header
		cgi.print content
	end

end
