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
		checks_and_settings(root)
	end

	def build_page
		file_on_disk = find_file_from_page(@page.uri)
		if file_on_disk.nil?
			render_error "NOT_FOUND", "Page #{@page.uri}"
		else
			flash(:debug, "Found file #{file_on_disk}")
			render_file(file_on_disk)
		end
	end

	private

	def checks_and_settings(root)

		@site = Object.new

		@page = Object.new
		@page.class.module_eval { attr_accessor :title }
		@page.class.module_eval { attr_accessor :content }
		@page.class.module_eval { attr_accessor :layout }
		@page.class.module_eval { attr_accessor :layout_file }
		@page.class.module_eval { attr_accessor :uri }
		@page.uri = ENV['REQUEST_URI']

		@files = Object.new
		@urls  = Object.new

		ruby_version_installed = RUBY_VERSION.split(".")
		ruby_version_required  = RUBY_VERSION_REQUIRED.split(".")

		if ((ruby_version_installed[0] < ruby_version_required[0]) or
			(ruby_version_installed[1] < ruby_version_required[1]) or
			(ruby_version_installed[2] < ruby_version_required[2]))
			render_error "SERVER_ERROR", "Incorrect Ruby version", "You have #{RUBY_VERSION} installed", "PIP requires #{RUBY_VERSION_REQUIRED} or higher"
		end

		set_settings "#{root}/config/pip.yml"
		set_settings "#{root}/config/site.yml"

	end

	def debug_page
		debug = ""
		debug << "<h1>Debug</h1>"
		debug << "<p>#{cgi.params.inspect}</p>"
		debug << "<p>Uri = " + "#{ENV['REQUEST_URI']}</p>"
		debug << "<p>Site Name = #{@site_name}</p>"
		render(debug)
	end

	def set_settings(file)
		YAML::ENGINE.yamler= 'syck' if defined?(YAML::ENGINE)

		if FileTest.exist?(file)
			yml = YAML::load_file(file)
			yml.each_pair do |section, keys|
				instance_variable_set("@#{section}".to_sym, Object.new) unless defined? "@#{section}".to_sym
				keys.each_pair do |setting,value|
					instance_variable_get("@#{section}".to_sym).class.module_eval { attr_accessor "#{setting}".to_sym }
					instance_variable_get("@#{section}".to_sym).send("#{setting}=", value)
				end
			end
			flash(:info, "@site => #{CGI::escapeHTML(@site.inspect.to_s)}")
			flash(:info, "@page => #{CGI::escapeHTML(@page.inspect.to_s)}")
		else
			render_error "SERVER_ERROR", "Can't find config file #{file}"
		end
	end

	def render_file(page_fragment_file_path)
		if page_fragment_file_path =~ /\.rhtml$/
			input = File.read(page_fragment_file_path)
			page_content =  ERB.new(input).result(binding)
			@page.title  = (extract_title(page_content) || @page.title_default) + @page.title_suffix
		else
			fragment = fetch_contents_of(page_fragment_file_path)
			page_content = clean_page(fragment)
			@page.title  = (extract_title(page_content) || @page.title_default) + @page.title_suffix
		end
		render_templated_content page_content
	end

	def render(content)
		@page.content = content
		flash(:debug, "rendering layout-free content")
		output = ERB.new(@page.content).result(binding)
		deliver(output)
	end

	def render_error(code, *content_strings)
		template = "
		<style>
			body {
				font-family: helvetica;
			}
			h1 {
				color: #FF0033;
				font-size: 20px;
			}
			p {
				font-size: 18px;
				color: #FF6633;
			}
		</style>
		<h1>Error</h1>
		<% for line in content_strings %>
			<p><%= line %></p>
		<% end %>"
		flash(:debug, "rendering error")
		output = ERB.new(template).result(binding)
		deliver(output, code)
	end

	def render_templated_content(content, template=nil)
		@page.content = content

		@page.layout  = template.nil? ? @page.layout_default : template
		@page.layout  = @layout if @layout
		@page.layout_file = "#{APP_ROOT}/#{@files.layouts}/#{@page.layout}.rhtml"

		render_error "SERVER_ERROR", "Can't find layout '#{@page.layout}'" if(!FileTest.exist?(@page.layout_file))

		outline = File.read(@page.layout_file)
		flash(:debug, "rendering content with layout: #{@page.layout} at #{@page.layout_file}")
		output = ERB.new(outline).result(binding)
		deliver(output)
	end

	def deliver(content, code="OK")
		cgi = CGI.new("html4")
		cgi.print cgi.header("status" => code)
		cgi.print content
		cgi.print @flash if @pip.debug
		Process.exit
	end

end
