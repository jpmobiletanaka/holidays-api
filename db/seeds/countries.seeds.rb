[
  { country_code: :cn, en_name: 'China', ja_name: '中国' },
  { country_code: :jp, en_name: 'Japan', ja_name: '日本' },
  { country_code: :kr, en_name: 'Korea', ja_name: '韓国' },
  { country_code: :tw, en_name: 'Taiwan', ja_name: '台湾' },
  { country_code: :th, en_name: 'Thailand', ja_name: 'タイ' },
  { country_code: :us, en_name: 'USA', ja_name: 'アメリカ合衆国' }
].each { |attrs| Country.find_or_create_by(attrs) }
