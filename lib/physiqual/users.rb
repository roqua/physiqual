module Physiqual
  class Users
    def export
      csv = ''
      export_lines do |line|
        csv << line + "\n"
      end
      csv
    end

    private

    def export_lines(&_block)
      headers = %w[user_id service_provider]
      yield format_headers(headers)
      Physiqual::User.includes(:physiqual_token).find_each do |user|
        vals = {}
        vals['user_id'] = user.user_id
        vals['service_provider'] = user.physiqual_token.class.friendly_name if user.physiqual_token
        yield format_hash(headers, vals)
      end
    end

    def format_headers(headers)
      r = ''
      headers.each do |header|
        r += ';' if r != ''
        r += "\"#{header}\""
      end
      r
    end

    def format_hash(headers, hsh)
      r = ''
      headers.each_with_index do |header, idx|
        r += ';' if idx != 0
        r += "\"#{hsh[header]}\"" unless hsh[header].nil?
      end
      r
    end
  end
end
