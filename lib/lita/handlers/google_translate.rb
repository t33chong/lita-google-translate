require "to_lang"

module Lita
  module Handlers
    class GoogleTranslate < Handler
      README = "https://github.com/tristaneuan/lita-google-translate#supported-languages"

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
      route(/!interpret/i, :interpret_stop, command: false)
      route(
        /^languages/i, :languages, command: true,
        help: {t("help.languages_key") => t("help.languages_value")}
      )

      on :message_received, :interpret_monitor

      def initialize(robot)
        super
        @@codes = ToLang::CODEMAP.each_value.map {|v| v.downcase}.to_set
      end

      def translate(response)
        response.reply get_translation(*parse_command(response.match_data))
      rescue InvalidLanguage => e
        response.reply t("invalid_language", code: e.message, url: README)
      end

      def interpret_start(response)
        from, to, text = parse_command(response.match_data)
        redis.set("#{response.user.id}:from", from)
        redis.set("#{response.user.id}:to", to)
        response.reply get_translation(from, to, text) unless text.nil?
      rescue InvalidLanguage => e
        response.reply t("invalid_language", code: e.message, url: README)
      end

      def interpret_monitor(payload)
        message = payload[:message]
        source = message.source
        user = source.user

        return if message.body.include?("!interpret")
        to = redis.get("#{user.id}:to")
        unless to.nil? || message.command?
          from = redis.get("#{user.id}:from")
          robot.send_messages(source, get_translation(from, to, message.body))
        end
      end

      def interpret_stop(response)
        redis.del("#{response.user.id}:to")
        redis.del("#{response.user.id}:from")
      end

      def languages(response)
        response.reply t("languages", url: README)
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

      def falsy(code)
        code.nil? || code.empty?
      end

    end

    class InvalidLanguage < Exception
    end

    Lita.register_handler(GoogleTranslate)
  end
end
