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

    def export_lines(&block)
      headers = %w(user_id service_provider)
      yield format_headers(headers)
      Physiqual::Token.includes(:physiqual_user).select('id, physiqual_user_id, type').find_each do |token|
        vals = {}
        vals['user_id'] = token.physiqual_user.user_id
        vals['service_provider'] = token.class.friendly_name
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
