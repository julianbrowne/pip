
##PIP

PIP (page-in-page) is a ludicrously simple web hosting framework designed to work in most ISP hosting environments.

PIP is designed to meet the following requirements:   

*	A web site is needed that is 99% static content
*	Owner of the site has access to some form of basic HTML editor
*	Owner of the site has no scripting/development knowledge
*	Pages across the site need to share various assets (images, header/footer fragments, etc)

PIP has the following dependencies:   

*	Hosting provider runs Apache 2
*	Hosting provider allows CGI scripts to be run
*	Hosting provider supports Ruby 1.8 or greater

###Installation

Most hosting providers supply a public\_html directory to put site content into. Copying all the PIP files into the directory above that (PIP comes with its own public\_html).

Edit the file:

	{PIP_ROOT}/config/settings.yml   
	
Stop and restart the Apache server
