#!/usr/bin/env ruby
#
# Create breadcrumb data for PowerShell module pages

Jekyll::Hooks.register :pages, :pre_render do |page|
  # Only modify pages related to PowerShell modules
  if page.url.include?('/modules/') || page.url.include?('/powershellmodules/')
    # Create an array to store breadcrumb data
    paths = page.url.split('/')
    paths.delete("")

    # Remove any empty segments and index.html
    paths = paths.reject { |p| p.empty? || p == 'index.html' }

    # Initialize breadcrumb array (this is what Chirpy theme uses internally)
    # The format appears to be an array of paths with special formatting
    breadcrumb_paths = []

    # Always add root path
    breadcrumb_paths << "/"

    # Add intermediate paths
    current_path = ""
    paths.each_with_index do |path, i|
      # Skip the last one as it will be handled separately
      next if i == paths.size - 1 && !page.url.end_with?('/')

      current_path += "/#{path}"
      breadcrumb_paths << current_path
    end

    # Set the breadcrumb data in page's data hash
    # This makes it available to the theme's breadcrumb rendering logic
    page.data['breadcrumb_paths'] = breadcrumb_paths

    # Add custom page title if needed for certain paths
    if page.url.include?('/powershellmodules/')
      page.data['breadcrumb_title'] = 'PowerShell Modules'
    elsif page.url.include?('/modules/') && paths.size >= 2
      module_name = paths[1].capitalize
      page.data['module_name'] = module_name

      if paths.size >= 3 && paths[2] == 'commands'
        page.data['command_section'] = true
      end
    end
  end
end
