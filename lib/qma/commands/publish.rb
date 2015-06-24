require 'uri'
require 'rest-client'
require 'multi_json'
require 'app_config'
require 'securerandom'
require 'lagunitas'
require 'ruby_apk'


command :publish do |c|
  @allowed_app = %w[ipa apk].freeze

  c.syntax = 'qma publish [options]'
  c.summary = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'
  c.description = '发布 iOS 或 Android 应用至穷游分发内测系统 (仅限 ipa/apk 文件)'

  c.option '-f', '--file FILE', '上传的 Android 或 iPhone 应用（仅限 apk 或 ipa 文件）'
  c.option '-n', '--name NAME', '设置应用名'
  c.option '-k', '--key KEY', '用户唯一的标识'
  c.option '-s', '--slug SLUG', '设置或更新应用的地址标识'
  c.option '-c', '--changelog CHANGLOG', '应用更新日志'
  c.option '--env ENV', '设置环境 (默认 development)'
  c.option '--config CONFIG', '自定义配置文件 (默认: ~/.qma)'

  c.action do |args, options|

    @file = args.first || options.file
    @name = options.name
    @user_key = options.key
    @changelog = options.changelog

    @env = options.env || ENV['QYER_ENV'] || 'development'
    @env = @env.downcase.to_sym if @env

    @configuration_file = options.config || File.join(File.expand_path('~'), '.qma')

    determine_qyer_env!
    determine_configuration_file!
    determine_file!
    determine_user_key!

    parse_app!

    send("publish_#{@file_extname}!")
  end

  private

    def publish_app(params)
      say "组装上传数据..."
      say "-> 应用: #{params[:name]}"
      say "-> 标识: #{params[:identifier]}"
      say "-> 版本: #{params[:release_version]} (#{params[:build_version]})"
      say "-> 类型：#{params[:device_type]}"

      default_params = {
        multipart: true,
        file: File.new(@file, 'rb'),
        key: @user_key,
        changelog: @changelog
      }

      params.merge!(default_params)
      url = URI.join(AppConfig.host, 'api/app/upload').to_s

      begin
        say "上传应用中"
        say_warning "API: #{url}" if $verbose
        say_warning "params: #{params.to_s}" if $verbose

        res = RestClient.post(url, params) do |response, request, result, &block|
          case response.code
          when 200..444
            response
          else
            response.return!(request, result, &block)
          end
        end

        case res.code
        when 200
          data = MultiJson.load res

          say "上传成功"
          say URI.join(AppConfig.host, '/apps/', data['slug']).to_s
        when 400..428
          data = MultiJson.load res

          say "[#{res.code}] #{data['error']}"
          if data['reason'].count > 0
            data['reason'].each do |key, message|
              say " * #{key} #{message}"
            end
          end
        end
      rescue Exception => e
        say "[ERROR] " + e.to_s
      end
    end

    def parse_app!
      say "解析 #{@file_extname} 应用的内部参数..."
      @app = case @file_extname
      when 'ipa'
        Lagunitas::IPA.new(@file).app
      when 'apk'
        Android::Apk.new(@file)
      end
    end

    def publish_ipa!
      @name ||= @app.display_name || @app.info['CFBundleName']

      publish_app({
        identifier: @app.identifier,
        name: @name,
        release_version: @app.short_version,
        build_version: @app.version,
        device_type: 'iPhone',
      })
    end

    def publish_apk!
      @name ||= @app.label
      publish_app({
        identifier: @app.manifest.package_name,
        name: @name,
        release_version: @app.manifest.version_name,
        build_version: @app.manifest.version_code,
        device_type: 'Android',
      })
    end

    def determine_configuration_file!
      say_warning '检测配置文件...' if $verbose

      if @configuration_file.to_s.empty? || ! File.exists?(@configuration_file)
        say_error '配置文件不存在 (默认: ~/.qma)' and abort
      end

      AppConfig.setup!(yaml: @configuration_file, env: @env)

      if AppConfig.host.to_s.empty?
        say_error "host 为空，请在配置文件更新: #{@configuration_file}" and abort
      end

      unless AppConfig.host =~ /\A#{URI::regexp}\z/
        say_error "host 不是有效域名格式，请在配置文件更新: #{@configuration_file}" and abort
      end
    end

    def determine_file!
      if @file.to_s.empty?
        say_error "请填写应用路径(仅限 ipa/apk 文件):" and abort
      end

      if File.exists?(@file)
        @file_extname = File.extname(@file).delete('.')
        unless @allowed_app.include?(@file_extname)
          say_error "应用仅接受 ipa/apk 文件" and abort
        end
      else
        say_error "输入的文件不存在" and abort
      end
    end

    def determine_user_key!
      @user_key ||= ask "User Token:"
    end

    def determine_qyer_env!
      say_warning "使用环境: #{@env}" if $verbose

      envs = [:development, :test, :production]
      unless envs.include?@env
        say_error "无效环境，仅限如下：#{envs.join(', ')}" and abort
      end
    end
end
