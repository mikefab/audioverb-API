class Lng < ApplicationRecord
  has_and_belongs_to_many :nams, :join_table => "lngs_nams"
  has_many :entries, :through => :nams
  #has_and_belongs_to_many :clas, :join_table => "clas_lngs"
  has_many :clas
  has_many :verbs, :through => :clas
  #attr_accessible :cod, :lng

  def self.available_languages
    return Nam.all.map { |n| n.lng.lng.downcase!}.uniq
  end

  def self.seed_data
    countries = {
      "Abkhaz" => "abk", "Aceh (Achenese)" => "ace", "Acholi (Acoli)" => "ach", "Adyghe (Adygei)" => "ady", "Afar" => "aar", "Afrihili" => "afh", "Afrikaans" => "afr", "Afro-Asiatic" => "afa", "Ainu" => "ain", "Akan" => "aka", "Akkadian" => "akk", "Albanian" => "alb", "Aleut" => "ale", "Algonquian languages" => "alg", "Altai, Southern" => "alt", "Altaic" => "tut", "Amharic" => "amh", "Angika" => "anp", "Anuak (Anywa)" => "anu", "Apache languages" => "apa", "Arabic" => "ara", "Aragonese" => "arg", "Aramaic" => "arc", "Arapaho" => "arp", "Arawak" => "arw", "Armenian" => "arm", "Artificial" => "art", "Assamese" => "asm", "Asturian (Astur-Leonese)" => "ast", "Athapascan languages" => "ath", "Austronesian" => "map", "Avar (Avaric)" => "ava", "Avestan" => "ave", "Awadhi" => "awa", "Aymara" => "aym", "Azerbaijani" => "aze", "Bali (Balinese)" => "ban", "Baltic" => "bat", "Baluchi" => "bal", "Bamanankan (Bambara)" => "bam", "Bamileke languages" => "bai", "Banda languages" => "bad", "Bantu" => "bnt", "Basaa (Basa)" => "bas", "Bashkir" => "bak", "Basque" => "baq", "Batak languages" => "btk", "Bedawi (Beja, Bedawiyet)" => "bej", "Belarusan (Belarusian)" => "bel", "Bemba" => "bem", "Bengali" => "ben", "Berber" => "ber", "Bhojpuri" => "bho", "Bihari" => "bih", "Bikol (Bicolano)" => "bik", "Bilen (Blin, Bilin)" => "byn", "Bislama" => "bis", "Blackfoot (Siksika)" => "bla", "Blissymbols (Blissymbolics/Bliss)" => "zbl", "Bosnian" => "bos", "Braj Bhasha" => "bra", "Breton" => "bre", "Bugis (Buginese)" => "bug", "Bulgarian" => "bul", "Buriat" => "bua", "Burmese (Myanmar)" => "bur", "Caddo" => "cad", "Carib (Galibi)" => "car", "Catalan" => "cat", "Caucasian" => "cau", "Cebuano" => "ceb", "Celtic" => "cel", "Central American Indian" => "cai", "Chagatai" => "chg", "Chamic languages" => "cmc", "Chamorro" => "cha", "Chechen" => "che", "Cherokee" => "chr", "Cheyenne" => "chy", "Chibcha" => "chb", "Chinese" => "chi_hans", "Chinese (Traditional)" => "chi_hant", "Chinese, Yue (Cantonese)" => "yue", "Chinook Wawa (Chinook Pidgin)" => "chn", "Chipewyan" => "chp", "Choctaw" => "cho", "Chuukese" => "chk", "Chuvash" => "chv", "Classical Nepal Bhasa" => "nwc", "Coptic" => "cop", "Cornish" => "cor", "Corsican" => "cos", "Cree" => "cre", "Creoles and pidgins (English-based)" => "cpe", "Creoles and pidgins (French-based)" => "cpf", "Creoles and pidgins (Portuguese-based)" => "cpp", "Crimean Turkish (Crimean Tatar)" => "crh", "Croatian" => "scr", "Cushitic" => "cus", "Czech" => "cze", "Dakota" => "dak", "Dangme (Adangme)" => "ada", "Danish" => "dan", "Dargwa" => "dar", "Dari, Zoroastrian" => "gbz", "Delaware" => "del", "Digo" => "dig", "Dinka" => "din", "Dogri" => "doi", "Dogrib" => "dgr", "Dravidian" => "dra", "Duala" => "dua", "Duruma" => "dug", "Dutch" => "dut", "Dzhidi (Judeo-Persian)" => "jpr", "Dzongkha (Bhutani)" => "dzo", "Edo (Bini, Benin)" => "bin", "Efik" => "efi", "Egyptian (Ancient)" => "egy", "Ekajuk" => "eka", "Elamite" => "elx", "English" => "eng", "Erzya" => "myv", "Esperanto" => "epo", "Estonian" => "est", "Eton" => "eto", "Ewondo" => "ewo", "Fang" => "fan", "Fanti" => "fat", "Faroese" => "fao", "Fijian" => "fij", "Filipino (Pilipino)" => "fil", "Finnish" => "fin", "Finno-Ugrian" => "fiu", "Fon" => "fon", "Franco-Provençal (Arpitan)" => "frp", "French (Canada)" => "fre_ca", "French" => "fra", "Frisian, Eastern" => "frs", "Frisian, Northern" => "frr", "Frisian, Western" => "fry", "Friulian" => "fur", "Fulah" => "ful", "Fur" => "fvr", "Ga" => "gaa", "Gaelic, Scottish (Gàidhlig)" => "gla", "Galician" => "glg", "Ganda (Luganda)" => "lug", "Gayo" => "gay", "Gbaya (Central African Republic)" => "gba", "Geez" => "gez", "Georgian" => "geo", "German" => "ger", "Germanic" => "gem", "Gikuyu (Kikuyu)" => "kik", "Gondi" => "gon", "Gorontalo" => "gor", "Gothic" => "got", "Grebo" => "grb", "Greek" => "gre", "Guarani" => "grn", "Gujarati" => "guj", "Gwich'in" => "gwi", "Haida" => "hai", "Haitian Creole" => "hat", "Hausa" => "hau", "Hawaiian" => "haw", "Hebrew" => "heb", "Herero" => "her", "Hiligaynon" => "hil", "Himachali" => "him", "Hindi" => "hin", "Hittite" => "hit", "Hmong" => "hmn", "Hungarian" => "hun", "Hupa" => "hup", "Iban" => "iba", "Icelandic" => "ice", "Ido" => "ido", "Igbo" => "ibo", "Ijo languages" => "ijo", "Ilocano (Iloko)" => "ilo", "Indic" => "inc", "Indo-European" => "ine", "Indonesian" => "ind", "Ingush" => "inh", "Interlingua" => "ina", "Interlingue (Occidental)" => "ile", "Inuktitut" => "iku", "Inuktitut, Greenlandic (Kalaallisut)" => "kal", "Inupiaq" => "ipk", "Iranian" => "ira", "Irish" => "gle", "Iroquoian languages" => "iro", "Italian" => "ita", "Japanese" => "jpn", "Javanese" => "jav", "Jingpho (Kachin)" => "kac", "Judeo-Arabic" => "jrb", "Jula (Dyula)" => "dyu", "Kabardian" => "kbd", "Kabyle" => "kab", "Kalenjin" => "kln", "Kalmyk-Oirat" => "xal", "Kamba" => "kam", "Kamba (Camba)" => "xba", "Kannada" => "kan", "Kanuri" => "kau", "Karachay-Balkar" => "krc", "Karakalpak" => "kaa", "Karelian" => "krl", "Karen languages" => "kar", "Kashmiri" => "kas", "Kashubian" => "csb", "Kawi" => "kaw", "Kazakh" => "kaz", "Khasi" => "kha", "Khmer (Cambodian)" => "khm", "Khoisan" => "khi", "Khotanese" => "kho", "Khowar" => "khw", "Kirghiz (Kyrgyz)" => "kir", "Kiribati (Gilbertese)" => "gil", "Klingon" => "tlh", "Komi" => "kom", "Kongo" => "kon", "Konkani" => "kok", "Korean" => "kor", "Kosraean" => "kos", "Kpelle" => "kpe", "Kru languages" => "kro", "Kumam" => "kdi", "Kumyk" => "kum", "Kurdish" => "kur", "Kurux (Kurukh)" => "kru", "Kutenai" => "kut", "Kwanyama (Kuanyama)" => "kua", "Ladino" => "lad", "Lahnda" => "lah", "Lamba" => "lam", "Land Dayak languages" => "day", "Lango (Uganda)" => "laj", "Lao" => "lao", "Latin" => "lat", "Latvian" => "lav", "Lezgi (Lezghian)" => "lez", "Limburgisch (Limburgs Plat)" => "lim", "Lingala" => "lin", "Lithuanian" => "lit", "Lojban" => "jbo", "Lozi" => "loz", "Luba-Kasai (Luba-Lulua)" => "lua", "Luba-Katanga" => "lub", "Luiseño" => "lui", "Lunda" => "lun", "Luo (Dholuo/Nilotic Kavirondo)" => "luo", "Luxembourgish (Letzeburgisch)" => "ltz", "Luyia (Luluyia/Luhya)" => "luy", "Maasai" => "mas", "Macedonian" => "mac", "Madi" => "grg", "Madura (Madurese)" => "mad", "Magahi" => "mag", "Maithili" => "mai", "Makasar" => "mak", "Malagasy" => "mlg", "Malay" => "may", "Malayalam" => "mal", "Maldivian (Divehi)" => "div", "Maltese" => "mlt", "Manchu" => "mnc", "Mandar" => "mdr", "Mandingo" => "man", "Maninkakan, Western  (Malinka)" => "mlq", "Manobo languages" => "mno", "Manx (Manx Gaelic)" => "glv", "Maori" => "mao", "Mapudungun (Mapuche)" => "arn", "Marathi" => "mar", "Mari" => "chm", "Marshallese" => "mah", "Marwari" => "mwr", "Masaba (Lugisu)" => "myx", "Mayan languages" => "myn", "Mbundu (Kimbundu)" => "kmb", "Meitei (Manipuri)" => "mni", "Mende" => "men", "Micmac (Mi'kmaq)" => "mic", "Middle Irish" => "mga", "Minangkabau" => "min", "Miranda do Douro (Mirandese)" => "mwl", "Mizo (Lushai)" => "lus", "Mohawk" => "moh", "Moksha" => "mdf", "Moldavian" => "mol", "Mon-Khmer" => "mkh", "Mongo-Nkundu (Mongo)" => "lol", "Mongolian" => "mon", "Motu, Hiri" => "hmo", "Multiple languages" => "mul", "Munda languages" => "mun", "Muskogee (Creek)" => "mus", "Mískito" => "miq", "Mòoré (Mossi)" => "mos", "N'Ko" => "nqo", "Nahuatl languages" => "nah", "Napoletano-Calabrese" => "nap", "Nauruan" => "nau", "Navajo (Navaho)" => "nav", "Ndebele (Ndebele Northern)" => "nde", "Ndebele (Nrebele)" => "nbl", "Ndonga" => "ndo", "Nepali" => "nep", "Newar (Nepal Bhasa/Newari)" => "new", "Nias" => "nia", "Niger-Kordofanian" => "nic", "Nilo-Saharan languages" => "ssa", "Niue (Niuean)" => "niu", "No linguistic content" => "zxx", "Nogai" => "nog", "North American Indian" => "nai", "Northern Pastaza Quichua" => "qvz", "Norwegian" => "nor", "Norwegian, Bokmål (Bokmaal)" => "nob", "Norwegian, Nynorsk" => "nno", "Nubian languages" => "nub", "Nuer" => "nus", "Nyamwezi" => "nym", "Nyanja (Chinyanja/Chewa)" => "nya", "Nyankore (Nyankole)" => "nyn", "Nyoro (Runyoro)" => "nyo", "Nzima" => "nzi", "Occitan" => "oci", "Ojibwa" => "oji", "Okiek (Akiek)" => "oki", "Olu'bo (Lulu`Bo/Luluba/Lulubo)" => "lul", "Oriya" => "ori", "Oromo" => "orm", "Osage" => "osa", "Osetin (Ossete/Ossetian)" => "oss", "Otomian languages" => "oto", "Pahlavi" => "pal", "Palauan" => "pau", "Pali" => "pli", "Pampangan (Pampango)" => "pam", "Pangasinan" => "pag", "Panjabi (Punjabi)" => "pan", "Panjabi, Mirpur" => "pmu", "Papiamentu (Papiamento)" => "pap", "Papuan (Other)" => "paa", "Pashto, Central (Mahsudi)" => "pst", "Persian (Farsi)" => "per", "Philippine" => "phi", "Phoenician" => "phn", "Pidgin, Nigerian (Nigerian Pidgin English)" => "pcm", "Pohnpeian" => "pon", "Polish" => "pol", "Portuguese (Brazil)" => "por_br", "Portuguese (Portugal)" => "por_pt", "Prakrit languages" => "pra", "Provençl" => "pro", "Pushto" => "pus", "Quechua" => "que", "Rajasthani" => "raj", "Rapa Nui" => "rap", "Rarotongan" => "rar", "Romance" => "roa", "Romanian" => "rum", "Romanian, Macedo (Aromanian)" => "rup", "Romansch" => "roh", "Romany" => "rom", "Rundi (Kirundi)" => "run", "Russian" => "rus", "Rwanda (Kinyarwanda)" => "kin", "Saami, Skolt" => "sms", "Saami, South" => "smn", "Salishan languages" => "sal", "Samaritan Aramaic" => "sam", "Sami languages" => "smi", "Sami, Lule" => "smj", "Sami, Northern" => "sme", "Sami, Southern" => "sma", "Samoan" => "smo", "Sandawe" => "sad", "Sango" => "sag", "Sanskrit" => "san", "Santali" => "sat", "Sardinian" => "srd", "Sasak" => "sas", "Schwyzerdütsch (Alemannisch, Swiss German)" => "gsw", "Scots" => "sco", "Selkup" => "sel", "Semitic" => "sem", "Serbian" => "scc", "Serbo-Croatian" => "hbs", "Serer-Sine (Serer)" => "srr", "Shan" => "shn", "Shavian (English)" => "eng_shaw", "Shona" => "sna", "Shuar" => "jiv", "Sicilian" => "scn", "Sidamo" => "sid", "Sign Languages" => "sgn", "Sindhi" => "snd", "Sinhala (Sinhalese)" => "sin", "Sino-Tibetan languages" => "sit", "Siouan languages" => "sio", "Slave (Slavey, Athapascan)" => "den", "Slavic" => "sla", "Slavonic, Old Church" => "chu", "Slovak" => "slo", "Slovenian" => "slv", "Soga (Lusoga)" => "xog", "Sogdian" => "sog", "Somali" => "som", "Songhai languages" => "son", "Soninke" => "snk", "Sorbian languages" => "wen", "Sorbian, Lower" => "dsb", "Sorbian, Upper" => "hsb", "Sotho, Northern (Pedi)" => "nso", "Sotho, Southern" => "sot", "South American Indian" => "sai", "Spanish" => "spa", "Sranan (Sranan Tongo)" => "srn", "Sukuma" => "suk", "Sumerian" => "sux", "Sunda (Sundanese)" => "sun", "Susu" => "sus", "Swahili" => "swa", "Swati" => "ssw", "Swedish" => "swe", "Syriac" => "syr", "Tagalog" => "tgl", "Tahitian" => "tah", "Tai" => "tai", "Taino" => "tnq", "Tajiki (Tajik)" => "tgk", "Tamashek" => "tmh", "Tamazight, Tidikelt" => "tia", "Tamil" => "tam", "Tatar" => "tat", "Telugu" => "tel", "Terêna" => "ter", "Teso (Ateso/Iteso)" => "teo", "Tetun (Tetum)" => "tet", "Thai" => "tha", "Themne (Timne)" => "tem", "Tibetan" => "tib", "Tigre" => "tig", "Tigrigna (Tigrinya)" => "tir", "Tiv" => "tiv", "Tlingit (Tlingit)" => "tli", "Tok Pisin" => "tpi", "Tokelauan (Tokelau)" => "tkl", "Tonga (Bitonga)" => "toh", "Tonga (Chitonga)" => "tog", "Tongan (Tonga)" => "ton", "Tsimshian" => "tsi", "Tsonga" => "tso", "Tswana" => "tsn", "Tumbuka" => "tum", "Tupi languages" => "tup", "Tupinambá" => "tpn", "Turkish" => "tur", "Turkmen" => "tuk", "Tuvaluan (Tuvalu)" => "tvl", "Tuvin (Tuva)" => "tyv", "Twi" => "twi", "Udmurt" => "udm", "Ugaritic" => "uga", "Ukrainian" => "ukr", "Umbundu" => "umb", "Uncoded languages" => "mis", "Undetermined" => "und", "Urdu" => "urd", "Uyghur (Uighur)" => "uig", "Uzbek" => "uzb", "Vai" => "vai", "Venda" => "ven", "Vietnamese" => "vie", "Vlaams (Flemish)" => "vls", "Vod (Votic)" => "vot", "Volapük" => "vol", "Wakashan languages" => "wak", "Walloon" => "wln", "Waray-Waray" => "war", "Washo" => "was", "Welsh" => "wel", "Wolaytta (Wallamo)" => "wal", "Wolof" => "wol", "Xhosa" => "xho", "Yakut" => "sah", "Yao" => "yao", "Yapese" => "yap", "Yi, Sichuan" => "iii", "Yiddish" => "yid", "Yoruba" => "yor", "Yupik languages" => "ypk", "Zande languages" => "znd", "Zapotec" => "zap", "Zaza (Dimili/Dimli/Kirdki/Kirmanjki/Zazaki)" => "zza", "Zenaga" => "zen", "Zhuang (Chuang)" => "zha", "Zulu" => "zul", "Zuni" => "zun", "Éwé" => "ewe"
    }
    countries.each do |key, item|
      puts Lng.create!(lng: key, cod: item)
    end
  end

end
