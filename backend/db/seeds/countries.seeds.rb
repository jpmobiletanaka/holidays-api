[
  { country_code: :cn, en_name: 'China', ja_name: '中国', google_calendar_id: 'china' },
  { country_code: :jp, en_name: 'Japan', ja_name: '日本', google_calendar_id: 'japanese'},
  { country_code: :kr, en_name: 'Korea', ja_name: '韓国', google_calendar_id: 'south_korea' },
  { country_code: :tw, en_name: 'Taiwan', ja_name: '台湾', google_calendar_id: 'taiwan' },
  { country_code: :th, en_name: 'Thailand', ja_name: 'タイ', google_calendar_id: 'th' },
  { country_code: :hk, en_name: 'Hong Kong', ja_name: '香港', google_calendar_id: 'hong_kong' },
  { country_code: :sg, en_name: 'Singapore', ja_name: 'シンガポール', google_calendar_id: 'singapore' },
  { country_code: :my, en_name: 'Malaysia', ja_name: 'マレーシア', google_calendar_id: 'malaysia' },
  { country_code: :id, en_name: 'Indonesia', ja_name: 'インドネシア', google_calendar_id: 'indonesian' },
  { country_code: :ph, en_name: 'Philippines', ja_name: 'フィリピン', google_calendar_id: 'philippines' },
  { country_code: :vn, en_name: 'Vietnam', ja_name: 'ベトナム', google_calendar_id: 'vietnamese' },
  { country_code: :in, en_name: 'India', ja_name: 'インド', google_calendar_id: 'indian' },
  { country_code: :au, en_name: 'Australia', ja_name: 'オーストラリア', google_calendar_id: 'australian' },
  { country_code: :us, en_name: 'USA', ja_name: 'アメリカ合衆国', google_calendar_id: 'usa' },
  { country_code: :ca, en_name: 'Canada', ja_name: 'カナダ', google_calendar_id: 'canadian' },
  { country_code: :uk, en_name: 'United Kingdom', ja_name: 'イギリス', google_calendar_id: 'uk' },
  { country_code: :fr, en_name: 'France', ja_name: 'フランス', google_calendar_id: 'french' },
  { country_code: :de, en_name: 'Germany', ja_name: 'ドイツ', google_calendar_id: 'german' },
  { country_code: :it, en_name: 'Italy', ja_name: 'イタリア', google_calendar_id: 'italian' },
  { country_code: :ru, en_name: 'Russia', ja_name: 'ロシア', google_calendar_id: 'russian' },
  { country_code: :es, en_name: 'Spain', ja_name: 'スペイン', google_calendar_id: 'spain' },
].each do |attrs|
  country = Country.find_or_create_by(attrs.slice(:country_code, :en_name, :ja_name))
  country.update_column(:google_calendar_id, attrs[:google_calendar_id]) if country.google_calendar_id.blank?
end
