require "language_pack/spring"

module LanguagePack
  class Grails < Spring
    VMC_GRAILS_PLUGIN = "CloudFoundryGrailsPlugin".freeze
    GRAILS_WEB_DIR = "WEB-INF/lib/grails-web/".freeze

    CONTEXT_PARAMS = {
        contextConfigLocation: 'classpath:META-INF/cloud/cloudfoundry-auto-reconfiguration-context.xml'
    }.freeze

    SERVLET = {
        dispatcherServletClass: "org.codehaus.groovy.grails.web.servlet.GrailsDispatcherServlet"
    }.freeze

    def self.use?
      Dir.glob("#{GRAILS_WEB_DIR}/*.jar").any? || Dir.glob("#{WEBAPP_DIR}#{GRAILS_WEB_DIR}/*.jar").any?
    end

    def name
      "Grails"
    end

    private
    def configure_autostaging
      unless autostaging_disabled
        web_config.configure_autostaging_context_param
        web_config.configure_autostaging_servlet
        save_web_config(web_config.xml)
        copy_autostaging_jar File.join(webapp_path, "WEB-INF", "lib")
      end
    end

    def autostaging_disabled
      grails_config_file = File.join(webapp_path, "WEB-INF", "grails.xml")
      if File.exist?(grails_config_file)
        vmc_plugin_present(grails_config_file)
      else
        false
      end
    end

    def vmc_plugin_present grails_config_file
      grails_config = REXML::Document.new(open(grails_config_file))
      prefix = namespace_prefix(grails_config)
      plugins = REXML::XPath.match(grails_config, "//#{prefix}plugins/#{prefix}plugin[contains(normalize-space(), '#{VMC_GRAILS_PLUGIN}')]")
      plugins && !plugins.empty?
    end

    def namespace_prefix(grails_config)
      name_space = grails_config.root.namespaces.first
      if name_space
        "#{name_space.first}:"
      else
        ''
      end
    end
  end
end
