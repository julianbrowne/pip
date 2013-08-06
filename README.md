
##PIP

PIP (page-in-page) is a ludicrously simple web hosting framework designed to work in most ISP hosting environments.

PIP is designed to meet the following requirements:   

*	A web site is needed that is mostly static content
*	Owner of the site has access to some form of basic text/HTML editor
*	Owner of the site has little or no no scripting/development knowledge
*	Pages across the site need to share various assets (images, styling, header/footer fragments, etc)
*	Some pages need to be different than the others (different layout for example)
*	Some pages are full html whereas others are html clippings of paragraph fragments, headings etc

PIP has the following dependencies:   

*	Hosting provider runs Apache 2
*	Hosting provider allows CGI scripts to be run
*	Hosting provider supports Ruby 1.8 or greater

###Installation

Most hosting providers supply a public\_html directory to put site content into. Copying all the PIP files into the directory above that (PIP comes with its own public\_html).

Edit the file:

	{PIP_ROOT}/config/settings.yml   
	
to cater for any special local settings.

Edit or create a new layout/site template file. The default can be found at:

	{PIP_ROOT}/public_html/layouts/default.rhtml
	
All site pages will use this layout by default. To use another layout for one particular file then simply make sure the layout exists:

	{PIP_ROOT}/public_html/layouts/happy.rhtml

(this alternative template is included)

And include the following in the page itself

	<% layout "happy" %>
	
And make sure the page is saved with a *.rhtml extension

Then just add pages as needed under:

	{PIP_ROOT}/public_html/pages

Pages can be linked to one another via full or relative URLs, just as if they were locally hosted. Some example files are included.

	{PIP_ROOT}/public_html/pages/index.html
	{PIP_ROOT}/public_html/pages/page.htm
	{PIP_ROOT}/public_html/pages/subfolder/page.html
	
###Making a Template

Here's a simple example template:

	<html>
	<head>
		<%= stylesheet_link_tag 'happy'  %>
		<title><%= @page.title %></title>
	</head>
	<body>
		<h1><%= @site.name %></h1>
		<%= @page.content %>
	</body>
	</html>   
   
This line
   
	<%= stylesheet_link_tag 'happy'  %>

sets the stylesheet to use for the template. By default PIP will look in:

	{PIP_ROOT}/public_html/stylesheets
	
for a file called happy.css

	<title><%= @page.title %></title>

When a site page is processed PIP looks for a <title>…</title> tag combination and stores that in @page.title (@page stores a whole collection of useful bits of data). By recalling it within the template the final rendered browser page title will be that extracted from the original page fragment - plus any site-wide suffix set in settings.yml

	<h1><%= @site.name %></h1>

As for @page, @site contains useful web site information. In this case we're setting <h1>…</h1> on all site pages to contain the name of the site set in settings.yml

	<%= @page.content %>

Finally this line renders the content of the page fragment within the enclosing template. So the browser gets something like:

	<html>
	<head>
	<!-- data from template -->
	<title>**title** from page fragment</title>
	</head>
	<body>
		<!-- other content from template -->
		<!-- **content** from page fragment -->
		<!-- other content from template -->
	</body>
	</html>

