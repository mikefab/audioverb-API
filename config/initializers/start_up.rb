KANJI_PINYIN = Kanji.all.inject({}){|hash, k| hash = k.pinyin; hash}
