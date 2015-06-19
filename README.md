# lita-google-translate

[![Build Status](https://travis-ci.org/tristaneuan/lita-google-translate.png?branch=master)](https://travis-ci.org/tristaneuan/lita-google-translate)
[![Coverage Status](https://coveralls.io/repos/tristaneuan/lita-google-translate/badge.png)](https://coveralls.io/r/tristaneuan/lita-google-translate)

**lita-google-translate** is a handler for [Lita](https://github.com/jimmycuadra/lita) that performs translation and live interpretation with Google Translate.

## Installation

Add lita-google-translate to your Lita instance's Gemfile:

``` ruby
gem "lita-google-translate"
```

## Configuration

In order to use this plugin, you must obtain a [Google Translate API key](https://cloud.google.com/translate/v2/pricing).

``` ruby
Lita.configure do |config|
  config.handlers.google_translate.api_key = "YOUR API KEY GOES HERE"
end
```

### Optional attributes
* `default_language` (String) - The code corresponding to the desired target language for translation and interpretation when none is explicitly given. Default: `en`

``` ruby
Lita.configure do |config|
  config.handlers.google_translate.default_language = "ja"
end
```

## Usage

Using the `translate` (or `t`) command will translate a given phrase. Source and/or target languages may be optionally specified using the syntax `translate(FROM:TO)`

```
<me>   lita: translate hola
<lita> Hello
<me>   lita: t(es) hello
<lita> Hola
<me>   lita: translate(zh-cn:fr) 你好
<lita> Bonjour
<me>   lita: translate(zh-cn:) 你好
<lita> Hello
<me>   lita: translate(:es) hello
<lita> Hola
```

Using the `interpret` command will interpret your messages on the fly until you type `!interpret`. Again, source and/or target languages may be optionally specified using the syntax `interpret(FROM:TO)`

```
<me>   lita: interpret(fr)
<me>   i don't want to talk to you anymore, you empty-headed animal food trough wiper
<lita> je ne veux plus parler de vous, vous animaux tête vide mangeoire glace
<me>   i fart in your general direction!
<lita> Je pète dans votre direction générale!
<me>   your mother was a hamster and your father smelled of elderberries
<lita> votre mère était un hamster et votre père avait une odeur de baies de sureau
<me>   !interpret
```

## Supported languages

This list can be accessed within your chat client by sending Lita the command: `languages`

Language | Code
--- | ---
Afrikaans | `af`
Albanian | `sq`
Arabic | `ar`
Belarusian | `be`
Bulgarian | `bg`
Catalan | `ca`
Simplified Chinese | `zh-CN`
Traditional Chinese | `zh-TW`
Croatian | `hr`
Czech | `cs`
Danish | `da`
Dutch | `nl`
English | `en`
Estonian | `et`
Filipino (Tagalog) | `tl`
Finnish | `fi`
French | `fr`
Galician | `gl`
German | `de`
Greek | `el`
Haitian Creole | `ht`
Hebrew | `iw`
Hindi | `hi`
Hungarian | `hu`
Icelandic | `is`
Indonesian | `id`
Irish (Gaelic) | `ga`
Italian | `it`
Japanese | `ja`
Latvian | `lv`
Lithuanian | `lt`
Macedonian | `mk`
Malay | `ms`
Maltese | `mt`
Norwegian | `no`
Persian (Farsi) | `fa`
Polish | `pl`
Portuguese | `pt`
Romanian | `ro`
Russian | `ru`
Serbian | `sr`
Slovak | `sk`
Slovenian | `sl`
Spanish | `es`
Swahili | `sw`
Swedish | `sv`
Thai | `th`
Turkish | `tr`
Ukrainian | `uk`
Vietnamese | `vi`
Welsh | `cy`
Yiddish | `yi`

## Credits

lita-google-translate's live interpretation feature was inspired by and adapted from [lita-translation](https://github.com/chua-mbt/lita-translation).

## License

[MIT](http://opensource.org/licenses/MIT)
