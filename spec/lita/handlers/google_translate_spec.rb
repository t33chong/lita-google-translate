require "spec_helper"

describe Lita::Handlers::GoogleTranslate, lita_handler: true do

  before do
    registry.config.handlers.google_translate.api_key = ENV["GOOGLE_TRANSLATE_API_KEY"]
  end

  it { is_expected.to route_command("translate hola").to(:translate) }
  it { is_expected.to route_command("translate(en) hola").to(:translate) }
  it { is_expected.to route_command("translate(es:en) hola").to(:translate) }
  it { is_expected.to route_command("translate(es:) hola").to(:translate) }
  it { is_expected.to route_command("translate[en] hola").to(:translate) }
  it { is_expected.to route_command("translate(es, en) hola").to(:translate) }
  it { is_expected.to route_command("translate(es>en) hola").to(:translate) }
  it { is_expected.to route_command("t() hola").to(:translate) }
  it { is_expected.to route_command("interpret(es:en)").to(:interpret_start) }
  it { is_expected.to route_command("interpret(es:en) hola").to(:interpret_start) }
  it { is_expected.to route("hola").to(:interpret_monitor) }
  it { is_expected.to route("!interpret").to(:interpret_stop) }
  it { is_expected.to route_command("languages").to(:languages) }

  context "with the default config" do

    describe "#translate" do

      it "translates with no parameters" do
        send_command "translate hola"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^hello$/i
      end

      it "translates with TO parameter" do
        send_command "translate(EL) hello"
        expect(replies.count).to eq 1
        expect(replies.first).to match "Γεια σας"
      end

      it "translates with TO and FROM parameters" do
        send_command "translate(zh-cn:de) 你好"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^hallo$/i
      end

      it "translates with FROM parameter" do
        send_command "translate(el:) Γεια σας"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^hello$/i
      end

      it "responds with an error message when an invalid source language is given" do
        send_command "translate(asdf:en) hej"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^'asdf' is not a valid language code\. For available languages, send me the command: languages$/
      end

      it "responds with an error message when an invalid target language is given" do
        send_command "translate(es:hjkl) hola"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^'hjkl' is not a valid language code\. For available languages, send me the command: languages$/
      end

    end

    describe "#interpret" do

      before(:each) do
        send_command "interpret"
      end

      it "interprets with no parameters" do
        send_message "hola"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^hello$/i
      end

      it "responds with an error message when an invalid language is given" do
        send_command "interpret(asdf)"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^'asdf' is not a valid language code\. For available languages, send me the command: languages$/
      end

      after(:each) do
        send_message "!interpret"
      end

    end

  end

  context "with a user-configured default language" do

    before(:each) do
      registry.config.handlers.google_translate.default_language = "es"
    end

    describe "#translate" do

      it "translates with no parameters" do
        send_command "translate hello"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^hola$/i
      end

    end

    describe "#interpret" do

      before(:each) do
        send_command "interpret"
      end

      it "interprets with no parameters" do
        send_message "hello"
        expect(replies.count).to eq 1
        expect(replies.first).to match /^hola$/i
      end

      after(:each) do
        send_message "!interpret"
      end

    end

  end

  describe "#languages" do

    it "responds with a list of languages and their codes" do
      send_command "languages"
      expect(replies.count).to eq 1
      expect(replies.first).to match /^afrikaans: af\nalbanian: sq\n/
    end

  end

end
