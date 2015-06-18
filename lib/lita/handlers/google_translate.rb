require "to_lang"

module Lita
  module Handlers
    class GoogleTranslate < Handler

      config :api_key, type: String, required: true
      config :default_language, type: String, default: "en"

      route(
        /^t(?:ranslate)?(?:[\[\(](?:(?<from>[\-[[:alpha:]]]*)[\:\>,]\s*)?(?<to>[\-[[:alpha:]]]*)[\]\)])?\s+(?<text>.+)/i,
        :translate, command: true, help: {
          t("help.translate_key") => t("help.translate_value"),
          t("help.translate_params_key") => t("help.translate_params_value")
        }
      )
      route(
        /^interpret(?:[\[\(](?:(?<from>[\-[[:alpha:]]]*)[\:\>,]\s*)?(?<to>[\-[[:alpha:]]]*)[\]\)])?(?:\s+(?<text>.+))?/i,
        :interpret_start, command: true,
        help: {t("help.interpret_key") => t("help.interpret_value")}
      )
      route(/./, :interpret_monitor, command: false)
      route(/!interpret/i, :interpret_stop, command: false)
      route(
        /^languages/i, :languages, command: true,
        help: {t("help.languages_key") => t("help.languages_value")}
      )

      def initialize(robot)
        super
        @@codes = ToLang::CODEMAP.each_value.map {|v| v.downcase}.to_set
      end

      def translate(response)
        begin
          response.reply get_translation(*parse_command(response.match_data))
        rescue InvalidLanguage => e
          response.reply format_error(e.message)
        end
      end

      def interpret_start(response)
        begin
          from, to, text = parse_command(response.match_data)
          redis.set("#{response.user.id}:from", from)
          redis.set("#{response.user.id}:to", to)
          response.reply get_translation(from, to, text) unless text.nil?
        rescue InvalidLanguage => e
          response.reply format_error(e.message)
        end
      end

      def interpret_monitor(response)
        return if response.message.body.include?("!interpret")
        to = redis.get("#{response.user.id}:to")
        unless to.nil? || response.message.command?
          from = redis.get("#{response.user.id}:from")
          response.reply get_translation(from, to, response.message.body)
        end
      end

      def interpret_stop(response)
        redis.del("#{response.user.id}:to")
        redis.del("#{response.user.id}:from")
      end

      def languages(response)
        response.reply_privately ToLang::CODEMAP.each.map {|k,v| "#{k}: #{v}"}.join("\n")
      end

      private

      def parse_command(md)
        from = falsy(md[:from]) ? nil : md[:from]
        raise InvalidLanguage, from unless from.nil? || @@codes.include?(from.downcase)
        to = falsy(md[:to]) ? config.default_language : md[:to]
        raise InvalidLanguage, to unless @@codes.include?(to.downcase)
        text = md[:text]
        [from, to, text]
      end

      def get_translation(from, to, text)
        ToLang.start(config.api_key)
        falsy(from) ? text.translate(to) : text.translate(to, :from => from)
      end

      def format_error(code)
        "'#{code}' is not a valid language code. For available languages, send me the command: languages"
      end

      def falsy(code)
        code.nil? || code.empty?
      end

    end

    class InvalidLanguage < Exception
    end

    Lita.register_handler(GoogleTranslate)
  end
end
