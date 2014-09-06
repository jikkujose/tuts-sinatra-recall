xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Recall"
    xml.description "'cause you're too busy to remember"
    xml.link request.url
  end
end

@notes.each do |note|
    xml.item do
        xml.title escape_html(note.content)
        xml.link "#{request.url.chomp request.path_info}/#{note.id}"
        xml.guid "#{request.url.chomp request.path_info}/#{note.id}"
        xml.pubDate Time.parse(note.created_at.to_s).rfc822
        xml.description escape_html(note.content)
    end
end
