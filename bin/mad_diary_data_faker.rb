#!/usr/bin/env ./script/runner

print 'Percentage missings? (15) '
percent_missing = gets.strip.to_i || 15

print 'Convert to Rob array? (y/N) '
convert = gets.strip.downcase == "y" || false

@start_time = Time.zone.parse('2014-05-04 10:00')
mad_models = []

class MadModel
  include Virtus.model
  attribute :name, String
  attribute :questionnaire_name, String
  attribute :questionnaire_key, String
  attribute :open_from, DateTime
  attribute :open_till, DateTime
  attribute :completer_type, String
  attribute :completed_at, DateTime
  attribute :status, String
  attribute :completing_url, String
  attribute :values, Hash
  attribute :outcome, Hash
end

def defaults(mad_model)
  mad_model.name                = 'MAD-onderzoek dagboekvragenlijst'
  mad_model.questionnaire_name  = 'MAD-onderzoek dagboekvragenlijst'
  mad_model.questionnaire_key   = 'mad_diary'
  mad_model.completer_type      = 'patient'
  mad_model.completing_url      = nil
  mad_model.outcome             = outcome

  mad_model
end

def values
  values = {}

  (1..43).each do |question|
    values["v_#{question}"] = "#{Random.rand(100.0).round(2)}"
  end

  values['v_2']  = "#{Random.rand(2)}"
  values['v_28'] = "#{Random.rand(5) + 1}"
  values['v_29'] = "#{Random.rand(9) + 1}"
  values['v_30'] = "#{Random.rand(13) + 1}"
  values['v_32'] = "#{Random.rand(4) + 1}"
  values['v_33'] = "#{Random.rand(7) + 1}"
  values['v_34'] = "#{Random.rand(2)}"
  values
end

def outcome
  {
    'scores' => {},
    'action' => nil,
    'actions' => {},
    'alarm' => nil,
    'attention' => nil,
    'complete' => nil
  }
end

(0...90).each do |x|
  missing = Random.rand(100) < percent_missing

  m = MadModel.new

  m.open_from = @start_time + ((x % 3) * 6.hours)
  m.open_from += (x / 3).round * 1.day
  m.open_till = m.open_from + 1.hours

  if missing
    m.status = 'open'
    m.completed_at = nil
  else
    m.status = ProtocolSubscription::ROQUA_COMPLETED_STATE
    m.completed_at = m.open_from + Random.rand(60).minutes
    m = defaults(m)
    m.values = values
  end
  mad_models.push m
end
mad_models.shuffle

if convert
  mad_models = ListResponses.new.send(:sort_measurements, mad_models)
  mad_models = ResponseProcessor.convert_responses mad_models
end

puts mad_models.to_json
